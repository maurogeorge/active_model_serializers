require 'json_schema'

module ActiveModelSerializers
  module Test
    module Schema
      def assert_response_schema(schema_path = nil, message = nil)
        matcher = AssertResponseSchema.new(schema_path, response, message)
        assert(matcher.call, matcher.message)
      end

      class AssertResponseSchema
        attr_reader :schema_path, :response, :message

        def initialize(schema_path, response, message)
          @response = response
          @schema_path = schema_path || schema_path_default
          @message = message
        end

        def call
          status, errors = schema.validate(data)
          @message ||= errors.map(&:to_s).to_sentence
          status
        end

        private

        def controller_path
          response.request.filtered_parameters[:controller]
        end

        def action
          response.request.filtered_parameters[:action]
        end

        def schema_directory
          ActiveModelSerializers.config.schema_path
        end

        def schema_full_path
          "#{schema_directory}/#{schema_path}"
        end

        def schema_path_default
          "#{controller_path}/#{action}.json"
        end

        def schema_data
          JSON.parse(File.read(schema_full_path))
        end

        def schema
          JsonSchema.parse!(schema_data)
        end

        def data
          JSON.parse(response.body)
        end
      end
    end
  end
end
