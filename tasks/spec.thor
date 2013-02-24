require 'rspec'

class Rspec < Thor

  desc 'run_all', 'run all tests'
  def run_all
    RSpec::Core::Runner.run(%w(-I . spec/))
  end

end
