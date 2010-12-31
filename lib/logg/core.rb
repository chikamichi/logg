module Logg
  class Machine 
    attr_accessor :message, :namespace

    def self.method_missing(meth, *args, &block)
      @@loggy ||= ::Logg::Machine.new
      @@loggy.namespace = meth.to_s
      @@loggy.message   = (args.first.to_s == 'debug') ? nil : args.first.to_s
      @@loggy.send :output!
    end

    private

    def output!
      debug  = "#{Time.now} | "
      debug += "[#{self.namespace}] " unless self.namespace.nil?
      debug += self.message
      puts debug
      return debug
    end
  end

  module Er
    def self.included(base)
      if !base.respond_to?(:logger)
        base.instance_eval do
          def self.logger
            ::Logg::Machine
          end
        end
      else
        raise RuntimeError, "Cannot mixin Logg::Er as #{base}#logger, already defined."
      end
    end
  end
end
