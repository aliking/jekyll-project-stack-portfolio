# frozen_string_literal: true

module Jekyll
  module PageAsset
    class Renderer
      class << self
        attr_reader :type

        def type_renderers
          @type_renderers ||= {}
        end

        def inherited(subclass)
          unregistered_subclasses << subclass
        end

        def unregistered_subclasses
          @unregistered_subclasses ||= []
        end

        def register_type(value)
          @type = value.to_s.strip
          raise "Render helper #{name} has no registered type" if @type.empty?

          Renderer.type_renderers[@type] = self
          Renderer.unregistered_subclasses.delete(self)
        end

        def assert_all_registered!
          missing = unregistered_subclasses.reject { |klass| klass == self }
          return if missing.empty?

          names = missing.map { |klass| klass.name || klass.to_s }.sort.join(", ")
          raise "PageAsset helpers need to register a type. Check subclass(es): #{names}"
        end

        def new_by_type(type:, asset_path_arg:, rest:, params:)
          renderer = type_renderers[type.to_s] || self
          renderer.new(
            type: type,
            asset_path_arg: asset_path_arg,
            rest: rest,
            params: params
          )
        end
      end

      def initialize(type:, asset_path_arg:, rest:, params: )
        @type = type.to_s
        @asset_path_arg = asset_path_arg
        @target_asset_paths = target_asset_paths(asset_path_arg)
        @target_asset_path = @target_asset_paths[0]
        @rest = rest.to_s
        @params = params || {}
      end

      def render(context)
        include_vars = build_include_vars
        render_template(context, include_vars)
      end

      protected


      def target_asset_paths(target)
        if File.file?(target)
          [target]
        elsif File.directory?(target)
          Dir.children(target)
           .select { |entry| File.file?(File.join(target, entry)) }
           .sort_by(&:downcase)
        else
          # assume the path includes a tag and pass it. This may cause issues
          raise 'target page_asset file not found'
        end
      end

      def build_include_vars(extra={})
        {
          "asset_paths" => @target_asset_paths,
          "asset_path" => @target_asset_path,
          "rest" => @rest,
          "params" => @params,
      }.merge(extra)
      end

      def load_template(context)
        site = context.registers[:site]
        include_path = File.join(site.source, "_includes", "page_asset", "#{@type}.html")

        unless File.exist?(include_path)
          raise IOError, "page_asset: include file not found at #{include_path}"
        end

        Liquid::Template.parse(File.read(include_path))
      end

      def render_template(context, include_vars)
        template = load_template(context)
        context.stack do
          context["include"] = include_vars
          template.render(context)
        end
      end

    end
  end
end
