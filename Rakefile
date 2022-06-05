task :console do
  desc "Interactive console"
  require_relative 'config/application'
  Dir.glob(File.expand_path('app/models/*.rb', __dir__)) do |file|
    require(file)
  end
  require 'pry'
  Pry.start
end

namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |_t, args|
    require_relative 'config/application'
    require "sequel/core"
    Sequel.extension :migration
    version = args[:version].to_i if args[:version]
    Sequel.sqlite(ENV.fetch("DATABASE_PATH"), logger: Logger.new($stderr)) do |db|
      Sequel::Migrator.run(db, "db/migrations", target: version, use_transactions: true)
    end
  end
end

task :sync do
  desc "Sync data from remote to local database"
  username = ENV.fetch('username')
  start_page_number = Integer(ENV.fetch('start_page_number'))
  skip_page_numbers = ENV.fetch('skip_page_numbers', '').split(',').map(&:to_i)
  require_relative 'config/application'
  require_relative 'app/models/user'
  require_relative 'app/runner'
  user = User.find_or_create(username: username)
  runner = Runner.new(user, start_page_number, skip_page_numbers)
  runner.run
end
