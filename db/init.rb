require 'sequel'
require 'sequel/extensions/migration'

env = ENV['RACK_ENV'] || 'development'
DB = Sequel.connect(ENV['DATABASE_URL'] || "sqlite://tmp/#{env}.sqlite")
Sequel::Migrator.apply(DB, 'db/migrations')
Sequel::Model.db = DB
