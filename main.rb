# frozen_string_literal: true

require_relative 'config/application'

require_relative 'app/models/artist'
require_relative 'app/models/album'
require_relative 'app/models/review'
require_relative 'app/models/user'

require 'nokogiri'
require 'faraday'

Thread.ignore_deadlock = true

PATH_PATTERN = 'https://www.allmusic.com/profile/gybo_96/reviews/all/recent/%d'

Page = Struct.new(:number, :document)

logger = Logger.new($stdout)
logger.level = :debug

fetch_queue = Thread::Queue.new
work_queue = Thread::Queue.new

user = User.find_or_create(username: 'gybo_96')

fetch_thread = Thread.new do
  loop do
    logger.debug('fetch_thread') { 'waiting for messages' }

    page_range = fetch_queue.pop
    if page_range.nil?
      logger.debug('fetch_thread') { 'queue closed' }
      break
    end
    logger.debug('fetch_thread') { "received page range to process: #{page_range}" }

    threads = []
    (page_range).each do |page_number|
      threads << Thread.new do
        url = PATH_PATTERN % page_number
        logger.debug('fetch_thread') { "fetch document at: #{url}" }

        response = Faraday.get(PATH_PATTERN % page_number)
        logger.debug('fetch_thread') { "fetch response: status=`#{response.status}`" }

        document = Nokogiri::HTML(response.body)
        logger.debug('fetch_thread') { "document parsed" }

        work_queue.push(document)
        logger.debug('fetch_thread') { "document sent to work_queue" }
      end
    end
    threads.each(&:join)
  end
  logger.debug('fetch_thread') { 'thread dying' }
end

work_thread = Thread.new do
  loop do
    logger.debug('work_thread') { 'waiting for messages' }

    document = work_queue.pop
    if document.nil?
      logger.debug('work_thread') { 'queue closed' }
      break
    end

    logger.debug('work_thread') { "processing document" }
    document.css('.single-user-review').each do |node|
      artist_name = node.css('.top .data .artist_link a').text.strip
      album_name = node.css('.top .data .album_link a').text.strip
      review_body = node.css('.middle.clearfix').text.strip
      review_rating_el = node.css('.top .data .user-collection-rating-td')
      review_rating = review_rating_el.attribute('class').value.split(' ').find.grep(/rating-average-\d+/).first.split('-').last.to_i

      artist = Artist.find_or_create(name: artist_name)
      album = Album.find_or_create(artist_id: artist.id, name: album_name)

      review = Review.find(album_id: album.id, user_id: user.id)
      unless review
        review = album.add_review(body: review_body, rating: review_rating, user_id: user.id)
      end

      logger.info('work_thread') do
        "Processed: artist=`#{[artist.id, artist.name]}` album=`#{[artist.id, album.name]}` review=`#{[review.id, "#{review.body[0..15]}..."]}`"
      end
    end
  end
  logger.debug('work_thread') { 'thread dying' }
end

fetch_queue.push(1..7)

fetch_thread.join
work_thread.join
