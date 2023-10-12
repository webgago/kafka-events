module Kafka
  module Events
    class Context
      extend Dry::Container::Mixin
      include Dry::Container::Mixin
      CONTEXT = "context".freeze

      class Registry < Dry::Container::Registry
        def call(container, key, item, options)
          @_mutex.synchronize do
            container[key] = factory.call(item, options)
          end
        end
      end

      class Resolver < Dry::Container::Resolver
        def call(container, key)
          item = container.fetch(key) do
            if block_given?
              return yield(key)
            else
              raise KeyError.new(%(key not found: "#{key}"), key: key, receiver: container)
            end
          end

          item.call
        end

        def key?(container, key)
          container.key?(key)
        end
      end

      config.registry = Registry.new
      config.resolver = Resolver.new

      def self.with_context(**params)
        context = new
        params.each { |key, value| context.register(key, value) }
        register(CONTEXT, context)
        yield
        register(CONTEXT, nil)
      end

      def self.current
        resolve(CONTEXT)
      end

      def self.get(key, &block)
        return if current.nil?

        if block_given?
          current.resolve(key)&.then(&block)
        else
          current.resolve(key)
        end
      end
    end
  end
end
