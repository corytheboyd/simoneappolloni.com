require_relative 'application'

require 'sequel'
DB = Sequel.sqlite(ENV.fetch('DATABASE_PATH'))
