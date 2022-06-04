# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'nokogiri'
require 'faraday'
require 'sequel'

# require_relative 'app/models/artist'

DATABASE_PATH = 'database.sqlite'
PATH_PATTERN = 'https://www.allmusic.com/profile/gybo_96/reviews/all/recent/%d'

DB = Sequel.sqlite(DATABASE_PATH)




puts Artist.create(name: 'Radiohead')

exit 0

response = Faraday.get(PATH_PATTERN % 1)
document = Nokogiri::HTML(response.body)

document.css('.single-user-review').each do |node|
  artist = node.css('.top .data .artist_link a').text.strip
  album = node.css('.top .data .album_link a').text.strip
  review = node.css('.middle.clearfix').text.strip

  rating_el = node.css('.top .data .user-collection-rating-td')
  rating = rating_el.attribute('class').value.split(' ').find.grep(/rating-average-\d+/).first.split('-').last.to_i

  p [artist, album, review, rating]
end
