$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'sequel'

Sequel::Model.db = Sequel.sqlite('tmp/test.sqlite')
