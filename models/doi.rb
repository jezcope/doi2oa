require 'sequel'

class Doi < Sequel::Model
  many_to_one :repository
end
