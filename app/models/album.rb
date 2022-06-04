class Album < Sequel::Model
  many_to_one :artists
end
