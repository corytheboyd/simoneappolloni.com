# frozen_string_literal: true

require_relative 'config/application'

require_relative 'app/models/artist'
require_relative 'app/models/album'
require_relative 'app/models/review'

# artist = Artist.create(name: 'Metallica')
# album = artist.add_album(name: 'Ride the Lightning')
# review = album.add_review(body: 'This slaps', rating: 9)

p [artist, album]
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
