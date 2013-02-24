require 'sequel'

Sequel::Model.db = Sequel.sqlite('tmp/test.sqlite')
