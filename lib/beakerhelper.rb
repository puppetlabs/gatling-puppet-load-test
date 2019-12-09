# frozen_string_literal: true

require "beaker"
require "beaker-pe"

# BeakerHelper class to get Beaker helpers outside of a Beaker run
class BeakerHelper
  include Beaker::DSL::Helpers
  include Beaker::DSL::Wrappers
  include Beaker::DSL::Roles
  include Beaker::DSL::Patterns

  def options
    { cache_files_locally: true }
  end

  def logger
    Beaker::Logger.new
  end
end
