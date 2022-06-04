class Album < Sequel::Model(DB)
  many_to_one :artists
  one_to_many :reviews
end
