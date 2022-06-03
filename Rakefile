require 'rubygems'
require 'bundler/settings'
require 'logger'

require 'dotenv'
Dotenv.load

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    require "sequel/core"
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.sqlite(ENV.fetch("DATABASE_PATH"), logger: Logger.new($stderr)) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end
end
