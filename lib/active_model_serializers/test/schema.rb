require 'json-schema'

module ActiveModelSerializers
  module Test
    module Schema
      def assert_response_schema(schema_path = nil)
        AssertResponseSchema.new(schema_path, response).call
      end

      class AssertResponseSchema
        attr_reader :schema_path, :response

        def initialize(schema_path, response)
          @response = response
          @schema_path = schema_path || schema_path_default
        end

        def call
          JSON::Validator.validate!(schema_full_path, response.body, strict: true)
        end

        private

        def controller_path
          response.request.filtered_parameters[:controller]
        end

        def action
          response.request.filtered_parameters[:action]
        end

        def schema_directory
          ActiveModel::Serializer.config.schema_path
        end

        def schema_full_path
          "#{schema_directory}/#{schema_path}"
        end

        def schema_path_default
          "#{controller_path}/#{action}.json"
        end
      end
    end
  end
end
