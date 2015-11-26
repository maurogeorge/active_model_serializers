require 'test_helper'

module ActiveModelSerializers
  module Test
    class SchemaTest < ActionController::TestCase
      class MyController < ActionController::Base
        def index
          render json: Profile.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
        end

        def show
          index
        end
      end

      tests MyController

      def test_that_assert_with_a_valid_schema
        get :index
        assert_response_schema
      end

      def test_that_raises_a_json_schema_error_with_a_invalid_schema
        get :show
        assert_raises RuntimeError do
          assert_response_schema
        end
      end

      def test_that_assert_with_a_custom_schema
        get :show
        assert_response_schema('custom/show.json')
      end

      def test_that_assert_with_a_hyper_schema
        get :show
        assert_response_schema('hyper_schema.json')
      end

      def test_that_assert_with_a_custom_schema_directory
        original_schema_path = ActiveModel::Serializer.config.schema_path
        ActiveModel::Serializer.config.schema_path = 'test/support/custom_schemas'

        get :index
        assert_response_schema

        ActiveModel::Serializer.config.schema_path = original_schema_path
      end
    end
  end
end
