module Logg
  class Machine 
    attr_reader :message, :namespace

    def method_missing(meth, *args, &block)
      @namespace = meth.to_s
      @message   = (args.first.to_s == 'debug') ? nil : args.first.to_s
      self.send :output!
    end

    private

    def output!
      debug  = "#{Time.now} | "
      debug += "[#{@namespace}] " unless @namespace.nil?
      debug += @message
      puts debug
      return debug
    end
  end

  module Er
    def self.included(base)
      if !base.respond_to?(:logger)
        base.instance_eval do
          def self.logger
            @@_logg_er ||= ::Logg::Machine.new
          end
        end

        def initialize
          super
          class << self
            self
          end.send(:define_method, :logger) do
            @_logg_er ||= ::Logg::Machine.new
          end
        end
      else
        raise RuntimeError, "Cannot mixin Logg::Er as #{base}#logger, already defined."
      end
    end
  end
end
