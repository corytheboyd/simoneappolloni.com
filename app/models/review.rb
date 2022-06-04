class Review < Sequel::Model(DB)
  many_to_one :albums
  many_to_one :users
end
