# frozen_string_literal: true

require_relative 'models/artist'
require_relative 'models/album'
require_relative 'models/review'

require 'nokogiri'
require 'faraday'

Thread.ignore_deadlock = true

PATH_PATTERN = 'https://www.allmusic.com/profile/gybo_96/reviews/all/recent/%d'

class Runner
  def initialize(user)
    @logger = Logger.new($stdout)
    @logger.level = :debug
    @fetch_queue = Thread::Queue.new
    @work_queue = Thread::Queue.new
    @user = user
  end

  def run
    fetch_thread = create_fetch_thread
    work_thread = create_work_thread
    fetch_queue.push(1..7)
    fetch_thread.join
    work_queue.close
    work_thread.join
  end

  private

  attr_reader :logger, :fetch_queue, :work_queue, :user

  def create_fetch_thread
    Thread.new do
      loop do
        logger.debug('fetch_thread') { 'waiting for messages' }

        page_range = fetch_queue.pop
        if page_range.nil?
          logger.debug('fetch_thread') { 'queue closed' }
          break
        end
        logger.debug('fetch_thread') { "received page range to process: #{page_range}" }

        threads = []
        last_page_number = page_range.max
        (page_range).each do |page_number|
          threads << Thread.new do
            url = PATH_PATTERN % page_number
            logger.debug('fetch_thread') { "fetch document at: #{url}" }

            response = Faraday.get(PATH_PATTERN % page_number)
            unless response.status == 200
              logger.debug('fetch_thread') { "fetch response has not ok status: #{response.status}" }
              Thread.current.kill
            end

            document = Nokogiri::HTML(response.body)
            logger.debug('fetch_thread') { "document parsed" }

            work_queue.push([document, page_number])
            logger.debug('fetch_thread') { "document sent to work_queue" }

            if page_number == last_page_number
              logger.debug('fetch_thread') { "getting next page range from last page pagination buttons" }

              next_last_page_number = -1
              document.css('.pagination > a').each do |link|
                link_page_number = link.text.to_i rescue -1
                if link_page_number > next_last_page_number
                  next_last_page_number = link_page_number
                end
              end

              if next_last_page_number > last_page_number
                next_page_range = ((last_page_number + 1)..next_last_page_number)
                logger.debug('fetch_thread') { "enqueue next range of pages: `#{next_page_range}`" }
                fetch_queue.push(next_page_range)
              else
                fetch_queue.close
              end
            end
          end
        end
        threads.each(&:join)
      end
      logger.debug('fetch_thread') { 'thread dying' }
    end
  end

  def create_work_thread
    Thread.new do
      loop do
        logger.debug('work_thread') { 'waiting for messages' }

        document, page_number = work_queue.pop
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

          thumbs_up = node.css('.thumbs-up-count').first.text.gsub(/\W+/, '').to_i rescue -1
          thumbs_down = node.css('.thumbs-up-count').first.text.gsub(/\W+/, '').to_i rescue -1

          review_attributes = {}.tap do |a|
            a[:page_url] = PATH_PATTERN % page_number
            a[:thumbs_up] = thumbs_up if thumbs_up > 0
            a[:thumbs_down] = thumbs_down if thumbs_down > 0
          end

          artist = Artist.find_or_create(name: artist_name)
          album = Album.find_or_create(artist_id: artist.id, name: album_name)

          review = Review.find(album_id: album.id, user_id: user.id)
          if review
            logger.debug('work_thread') { "updating review: id=`#{review.id}` attributes=`#{review_attributes}`" }
            review.update(**review_attributes) unless review_attributes.empty?
          else
            logger.debug('work_thread') { "creating review" }
            review = album.add_review(body: review_body, rating: review_rating, user_id: user.id, **review_attributes)
          end

          logger.info('work_thread') do
            "Processed: artist=`#{[artist.id, artist.name]}` album=`#{[artist.id, album.name]}` review=`#{[review.id, "#{review.body[0..15]}..."]}`"
          end
        end
      end
      logger.debug('work_thread') { 'thread dying' }
    end
  end
end
