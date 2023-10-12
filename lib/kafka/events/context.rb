module Kafka
  module Events
    class Context
      extend Dry::Container::Mixin
      include Dry::Container::Mixin
      CONTEXT = :__kafka_events_context

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
        context = Thread.current[CONTEXT] ||= new
        params.each { |key, value| context.register(key, value) }
        yield
        Thread.current[CONTEXT] = nil
      end

      def self.current
        Thread.current[CONTEXT]
      end

      def self.get(key, &block)
        return unless current

        if block_given?
          current.resolve(key)&.then(&block)
        else
          current.resolve(key)
        end
      end
    end
  end
end
