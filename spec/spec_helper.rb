$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'rspec'
require 'sequel'
require 'sequel/extensions/migration'
require 'factory_girl'
require 'vcr'

DB = Sequel.sqlite
Sequel::Migrator.apply(DB, 'db/migrations')
Sequel::Model.db = DB

FactoryGirl.find_definitions

VCR.configure do |c|  
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :faraday
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
