require 'active_model'
require 'active_support'
require 'action_controller'
require 'action_controller/railtie'
module ActiveModelSerializers
  mattr_accessor(:logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT)) }

  def self.config
    ActiveModel::Serializer.config
  end

  extend ActiveSupport::Autoload
  autoload :Model
  autoload :Callbacks
  autoload :Logging
end

require 'active_model/serializer'
require 'active_model/serializable_resource'
require 'active_model/serializer/version'
require 'active_model_serializers/test/schema'

require 'action_controller/serialization'
ActiveSupport.on_load(:action_controller) do
  ActiveSupport.run_load_hooks(:active_model_serializers, ActiveModelSerializers)
  include ::ActionController::Serialization
  ActionDispatch::Reloader.to_prepare do
    ActiveModel::Serializer.serializers_cache.clear
  end
  ActionController::TestCase.send(:include, ActiveModelSerializers::Test::Schema)
end

require 'active_model/serializer/railtie'
