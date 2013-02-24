require 'sequel'

class Repository < Sequel::Model
  plugin :validation_helpers

  one_to_many :dois
  
  def validate
    super

    validates_presence [:base_url]
  end
end
