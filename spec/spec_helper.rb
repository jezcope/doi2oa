$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'sequel'
require 'sequel/extensions/migration'
require 'factory_girl'

DB = Sequel.sqlite
Sequel::Migrator.apply(DB, 'db/migrations')
Sequel::Model.db = DB

FactoryGirl.find_definitions
