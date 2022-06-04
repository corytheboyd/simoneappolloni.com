class User < Sequel::Model(DB)
  one_to_many :reviews
end
