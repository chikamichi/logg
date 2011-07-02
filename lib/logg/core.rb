module Logg
  # Set to true to puts output using logger#debug default's method.
  ALWAYS_PUTS = false

  # A Machine is a logger core implementation, providing logger's definition
  # and output methods. It's not intented to be used directly but through the
  # Er mixin, within a class.
  class Machine
    class Render
      # Render a template. Just a mere proxy for Tilt::Template#render method,
      # the first argument being the filepath or file, and the latter,
      # the usual arguments for Tilt's #render.
      #
      # @param [String, #path, #realpath] path filepath or an object behaving
      #   like a legacy File
      # @param [Object] obj context object the template will be rendered within
      # @param [Hash] args rendering context
      # @option [Symbol] :as syntax engine
      # @option [Object] :data template's rendering contextual object
      # @option [Hash]   :locals template's locals
      # @return [String] the interpolated template
      #
      def render(path, *args)
        args = args.first
        path = detect_path(path)
        tpl  = fetch_template(args, path)
        tpl.render(args[:data], args[:locals])
      end

      def render_inline(content, *args)
        args   = args.first
        syntax = detect_syntax(args)
        res    = Object

        Better::Tempfile.open(['dummylogg', ".#{syntax}"]) do |f|
          f.write(content)
          f.rewind
          res = Tilt.new(f.path).render(args[:data], args[:locals])
        end
        res
      end

      def detect_path(path)
        if path.respond_to?(:path)
          path.path
        elsif path.respond_to?(:realpath)
          path.to_s
        elsif path.respond_to?(:to_s)
          path.to_s
        else
          raise ArgumentError, 'Missing file or a filepath.'
        end
      end

      def fetch_template(args, path)
        if args[:as]
          begin
            test_path = Pathname.new(path)
            raise ArgumentError, "Invalid filepath #{path}" unless test_path.file?
          rescue
            test_path = Pathname.new(path + ".#{args[:as].downcase}")
            raise ArgumentError, "Invalid filepath #{path}" unless test_path.file?
            path = test_path.to_s
          end
          Tilt.const_get("#{args[:as].downcase.capitalize}Template").new(path)
        else
          Tilt.new(path)
        end
      end

      def detect_syntax(options)
        unless options.has_key?(:as)
          raise ArgumentError, 'Missing template syntax specified as the :as option.'
        end
        options[:as].to_s
      end
    end

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

    # Define a custom logger, using a template. The template may be defined
    # within the block as a (multi-line) string, or one may reference a
    # file.
    #     # do whatever you want with data or anything else, for instance,
    #     send mails, tweet, then…
    #
    # Inline templates (defined within the block) make use of #render_inline
    # (indentation broken for the sake of example readibility):
    #
    #   logger.as(:custom) do |response|
    #     tpl = <<-TPL
    #       %h2 Query log report
    #       %span
    #         Statu:
    #         = data.status
    #       %span
    #         Response:
    #         = data.body
    #       %br/
    #     TPL
    #     puts render_inline(tpl, :as => :haml, :data => response)
    #   end
    #
    # With an external template, one should use the #render helper to, well,
    # render the template file. The extension will be used to infer the proper
    # rendering engine. If not provided or when a custom extension is used, one
    # may declare the template syntax.
    #
    #   logger.as(:custom) do |data|
    #     # do whatever you want with data or anything else, then…
    #     out = render('my/template.erb', :data => data)
    #     # one may then use out to send mails, log to file, tweet…
    #   end
    #
    #   logger.as(:custom) do |data|
    #     render('my/template', :as => :erb, :data => data)
    #   end
    #
    # See #render and #render_inline for more details.
    #
    # TODO: memoize the Render instance somehow? Or find another trick to
    # execute the block.
    #
    def as(method, *options, &block)
      # TODO: respond_to? if/else
      method  = method.to_sym
      options = options.first

      # Define the guard at class-level, if not already defined.
      if !eigenclass.respond_to?(method)
        eigenclass.send(:define_method, method) do |*args|
          Render.new.instance_exec(*args, &block)
        end
      end

      # Define the guard at instance-level by overriding #initialize, if not
      # already defined.
      eigenclass.send(:define_method, :new) do
        o = super
        if !o.respond_to?(method)
          o.send(:define_method, method) do |*args|
            Render.new.instance_exec(*args, &block)
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
      puts output if defined?(Logg::ALWAYS_PUTS) && Logg::ALWAYS_PUTS
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
