$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rspec'
require 'sequel'
require 'sequel/extensions/migration'
require 'factory_girl'

DB = Sequel.sqlite
Sequel::Migrator.apply(DB, 'db/migrations')
Sequel::Model.db = DB

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions
