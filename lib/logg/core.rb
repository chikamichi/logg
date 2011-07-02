module Logg
  # Set to true to puts output when using logger#debug default's method.
  ALWAYS_PUTS = true

  # A Dispatcher is a logger core implementation, providing logger's definition
  # and output methods. It's not intented to be used directly but through the
  # Er mixin, within a class.
  #
  class Dispatcher
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

    # The Dispatcher default behavior relies on #method_missing. It sets both the
    # message and a namespace, then auto-sends the order to output.
    #
    def method_missing(meth, *args, &block)
      @namespace = meth.to_s
      @message   = (args.first.to_s == 'debug') ? nil : args.first.to_s
      self.send :output!
    end

    def eigenclass
      class << self; self; end
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
    def as(method, &block)
      raise ArgumentError, 'Missing mandatory block' unless block_given?

      method  = method.to_sym

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

    # Default logging behavior. Outputs to $stdout using #puts and return
    # the message.
    #
    def output!
      output  = "#{Time.now} | "
      output += "[#{@namespace}] " unless @namespace.nil?
      output += @message
      puts output if defined?(Logg::ALWAYS_PUTS) && Logg::ALWAYS_PUTS
      return output
    end
  end

  # The Er module, when mixed-in a class, instantiates a Dispatcher and performs some
  # simple meta-programming on this receiver to add support for the logger. It thus
  # enable the receiver to use the logger's default implementation and/or define
  # custom loggers.
  #
  module Machine
    LOGGER = Logg::Dispatcher.new
    #NAME = (defined?(::Logg::LOG_METHOD) && ::Logg::LOG_METHOD) || :log
    NAME = :log

    def self.included(base)
      if !base.respond_to?(NAME)
        base.instance_eval do
          # Memoized logger for the receiver's class.
          #
          # TODO: add support for defining the logger under a different name than #log,
          # this means either defining a constant before mixin, or delaying the metaprog.
          class << self; self; end.instance_eval do
            define_method(NAME) do
              @@_logg_er ||= LOGGER
            end
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
        if !o.respond_to?(NAME)
          class << o; self; end.send(:define_method, NAME) do
            @_logg_er ||= LOGGER
          end
        end
        o
      end
    end
  end
end
