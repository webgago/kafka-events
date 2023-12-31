# frozen_string_literal: true

module Kafka
  module Events
    module Helpers
      def helper(name, &block)
        define_method(name) do
          if instance_variable_defined?("@#{name}")
            instance_variable_get("@#{name}")
          else
            instance_variable_set("@#{name}", instance_exec(&block))
          end
        end
      end
    end
  end
end
