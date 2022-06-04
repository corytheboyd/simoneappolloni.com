class Artist < Sequel::Model(DB)
  one_to_many :albums
end
