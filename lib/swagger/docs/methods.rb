require "active_support/core_ext/hash/deep_merge"
module Swagger
  module Docs
    module Methods
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def swagger_controller(controller, description)
          swagger_config[:controller] = controller
          swagger_config[:description] = description
        end

        def swagger_actions
          swagger_dsl = {}
          Array(@swagger_dsl).each do |action, controller, block|
            dsl = SwaggerDSL.call(action, controller, &block)
            swagger_dsl[action] ||= {}
            swagger_dsl[action].deep_merge!(dsl) { |key, old, new| Array(old) + Array(new) }
          end
          swagger_dsl
        end

        def swagger_models
          swagger_model_dsls ||= {}
          Array(@swagger_model_dsls).each do |model_name, controller, block|
            model_dsl = SwaggerModelDSL.call(model_name, controller, &block)
            swagger_model_dsls[model_name] = model_dsl
          end
          swagger_model_dsls
        end

        def swagger_config
          @swagger_config ||= {}
        end

        private

        def swagger_api(action, &block)
          @swagger_dsl ||= []
          @swagger_dsl << [action, self, block]
        end

        def swagger_model(model_name, &block)
          @swagger_model_dsls ||= []
          @swagger_model_dsls << [model_name, self, block]
        end
      end
    end
  end
end
