class Album < Sequel::Model
  many_to_one :artists
  one_to_many :reviews
end
