module Logg
  # A Machine is a logger core implementation, providing logger's definition
  # and output methods. It's not intented to be used directly but through the
  # Er mixin, within a class.
  class Machine
    attr_reader :message, :namespace

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

      # Define the guard at class-level if not already defined.
      if !eigenclass.respond_to?(method)
        eigenclass.send(:define_method, method) do |*args|
          yield *args
        end
      end

      # Define the guard at instance-level by overriding #initialize, if not
      # already defined.
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
      output  = "#{Time.now} | "
      output += "[#{@namespace}] " unless @namespace.nil?
      output += @message
      puts output unless defined?(Logg::NO_STDOUT) && Logg::NO_STDOUT
      return output
    end
  end

  # The Er module, when mixed-in a class, instantiates a Machine and performs some
  # simple meta-programming on this receiver to add support for the logger. It thus
  # enable the receiver to use the logger's default implementation and/or define
  # custom loggers.
  module Er
    LOGGER = Logg::Machine.new

    def self.included(base)
      if !base.respond_to?(:logger)
        base.instance_eval do
          # Memoized logger for the receiver's class.
          #
          # TODO: add support for defining the logger under a different name than #logger
          # this means either defining a constant before mixin, or delaying the metaprog.
          def self.logger
            @@_logg_er ||= LOGGER
          end
        end
      else
        raise RuntimeError, "Cannot mixin Logg::Er as #{base}#logger, method's already defined."
      end

      # Memoized logger for the receiver.
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
