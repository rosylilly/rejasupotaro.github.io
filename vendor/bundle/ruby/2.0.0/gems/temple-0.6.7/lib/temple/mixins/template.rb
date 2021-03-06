module Temple
  module Mixins
    # @api private
    module Template
      include DefaultOptions

      def compile(code, options)
        engine = options.delete(:engine)
        raise 'No engine configured' unless engine
        engine.new(options).call(code)
      end

      def register_as(*names)
        raise NotImplementedError
      end

      def create(engine, options)
        register_as = options.delete(:register_as)
        template = Class.new(self)
        template.disable_option_validator!
        template.default_options[:engine] = engine
        template.default_options.update(options)
        template.register_as(*register_as) if register_as
        template
      end
    end
  end
end
