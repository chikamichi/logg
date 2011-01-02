# Logg provides a module, Er, which a class can include (mixin) to gain
# logging helpers:
#
#   class Foo
#     include Logg::Er
#   end
#
#   Foo.logger.debug "message"
#   Foo.new.logger.debug "message"
#   Foo.new.logger.my_namespace "message"
#
# Both the class and class instances can access their logging machine
# through the +#logger+ (instance/class) method. Note each instances
# has its own machine, and the class' machine is also a different one.
#
module Logg
  class Machine 
    attr_reader :message, :namespace, :customs

    # The Machine is based on #method_missing. It auto-sets both the message
    # and the namespace internally, then auto-sends the order +:output!+.
    def method_missing(meth, *args, &block)
      @namespace = meth.to_s
      @message   = (args.first.to_s == 'debug') ? nil : args.first.to_s
      self.send :output!
    end

    def eigenclass
      class << self
        self
      end
    end

    def as(method, &block)
      # TODO: respond_to? if/else
      method = method.to_sym

      if !eigenclass.respond_to?(method)
        # Define the guard at class-level
        eigenclass.send(:define_method, method) do |*args|
          yield *args
        end
      end

      # Define the guard at instance-level
      eigenclass.send(:define_method, :new) do
        o = super
        if !o.respond_to?(method)
          o.send(:define_method, method) do |*args|
            yield *args
          end
        end
        o
      end
    end

    private

    # TODO: handle the output with a templating system
    def output!
      debug  = "#{Time.now} | "
      debug += "[#{@namespace}] " unless @namespace.nil?
      debug += @message
      puts debug
      return debug
    end
  end

  module Er
    LOGGER = Logg::Machine.new

    def self.included(base)
      if !base.respond_to?(:logger)
        base.instance_eval do
          def self.logger
            @@_logg_er ||= LOGGER
          end
        end
      else
        raise RuntimeError, "Cannot mixin Logg::Er as #{base}#logger, already defined."
      end

      base.extend RedefInit
    end

    module RedefInit
      def new *args, &block
        o = super
        if !o.respond_to?(:logger)
          class << o
            self
          end.send(:define_method, :logger) do
            @_logg_er ||= LOGGER
          end
        end
        o
      end
    end
  end
end
