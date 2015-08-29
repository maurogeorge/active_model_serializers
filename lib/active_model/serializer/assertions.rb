require 'json-schema'

module ActiveModel
  class Serializer
    module Assertions
      def assert_response_schema(schema_path = nil)
        controller_path = response.request.filtered_parameters[:controller]
        action = response.request.filtered_parameters[:action]
        schema_directory = ActiveModel::Serializer.config.schema_path
        schema_path ||= "#{controller_path}/#{action}.json"
        schema_full_path = "#{schema_directory}/#{schema_path}"
        JSON::Validator.validate!(schema_full_path, response.body, strict: true)
      end
    end
  end
end
