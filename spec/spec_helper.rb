$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'sequel'
require 'factory_girl'

Sequel::Model.db = Sequel.sqlite('tmp/test.sqlite')

FactoryGirl.find_definitions
