require 'sequel'

class Doi < Sequel::Model
  plugin :validation_helpers

  many_to_one :repository

  def validate
    super

    validates_presence [:repository, :doi]
  end

end
