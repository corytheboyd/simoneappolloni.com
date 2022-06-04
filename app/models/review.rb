class Review < Sequel::Model
  one_to_one :albums
end
