# frozen_string_literal: true

require_relative 'config/application'

require_relative 'app/models/artist'
require_relative 'app/models/album'
require_relative 'app/models/review'
require_relative 'app/models/user'

# artist = Artist.create(name: 'Metallica')
# album = artist.add_album(name: 'Ride the Lightning')
# review = album.add_review(body: 'This slaps', rating: 9)

# require 'faraday'
# PATH_PATTERN = 'https://www.allmusic.com/profile/gybo_96/reviews/all/recent/%d'
# response = Faraday.get(PATH_PATTERN % 1)

user = User.find_or_create(username: 'gybo_96')
p user

require 'nokogiri'
document = Nokogiri::HTML(File.read('response.html'))

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
    review = album.add_review(
      body: review_body,
      rating: review_rating,
      user_id: user.id,
    )
  end
  p [artist, album, review]
end
