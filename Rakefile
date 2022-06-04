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
      Sequel::Migrator.run(db, "db/migrations", target: version)
    end
  end
end
