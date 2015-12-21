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
          @document_store = JsonSchema::DocumentStore.new
          add_schema_to_document_store
        end

        def call
          json_schema.expand_references!(store: document_store)
          status, errors = json_schema.validate(response_body)
          @message ||= errors.map(&:to_s).to_sentence
          status
        end

        private

        ActiveModelSerializers.silence_warnings do
          attr_reader :document_store
        end

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

        def response_body
          JSON.parse(response.body)
        end

        def json_schema
          @json_schema ||= JsonSchema.parse!(schema_data)
        end

        def add_schema_to_document_store
          Dir.glob("#{schema_directory}/**/*.json").each do |path|
            schema_data = JSON.parse(File.read(path))
            extra_schema = JsonSchema.parse!(schema_data)
            document_store.add_schema(extra_schema)
          end
        end
      end
    end
  end
end
