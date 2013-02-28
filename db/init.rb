require 'sequel'
require 'sequel/extensions/migration'

DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://tmp/development.sqlite')
Sequel::Migrator.apply(DB, 'db/migrations')
Sequel::Model.db = DB
