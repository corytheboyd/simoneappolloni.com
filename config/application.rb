require 'rubygems'
require 'bundler/setup'
require 'logger'

require 'dotenv'
Dotenv.load

require 'sequel'
DB = Sequel.sqlite(ENV.fetch('DATABASE_PATH'))
