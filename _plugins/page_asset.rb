# frozen_string_literal: true

require_relative "../_lib/page_asset/renderer"

Dir[File.join(__dir__, "../_lib","page_asset", "*_renderer.rb")].sort.each do |renderer_file|
  require renderer_file
end

Jekyll::PageAsset::Renderer.assert_all_registered!

module Jekyll
  module PageAsset
    module TagHelpers
      private

      def parse_tag_markup(markup, context)
        normalized_markup = markup.to_s.strip
        return [nil, nil, "", {}] if normalized_markup.empty?

        # expand {{tags}}
        normalized_markup = normalized_markup.gsub(/\{\{\s*([^}]+)\s*\}\}/) do
          variable_path = $1.strip
          # Dynamically lookup the variable in Jekyll's context hierarchy
          context[variable_path].to_s
        end

        type, target, rest = normalized_markup.split(/\s+/, 3)
        rest ||= ""

        params = {}
        rest.scan(/(\w+)=(?:'([^']*)'|"([^"]*)"|(\S+))/) do |key, sq, dq, bare|
          params[key] = sq || dq || bare
        end

        [type, target, rest, params]
      end

      def tag_site(context)
        context.registers[:site]
      end

      def tag_page(context)
        context.registers[:page]
      end

      def project_slug_from_context(context)
        page = tag_page(context)
        page_url = page["url"] || page.url
        page_url.to_s.split("/").reject(&:empty?).last
      end

      def page_asset_root
        Jekyll.configuration.dig("page_asset", "asset_root") || "assets/project_media"
      end

      def page_asset_relative_path(context, *segments)
        project_slug = project_slug_from_context(context)
        return nil if project_slug.nil? || project_slug.empty?

        File.join(page_asset_root, project_slug, *segments.compact)
      end

      def page_asset_source_path(context, *segments)
        relative_path = page_asset_relative_path(context, *segments)
        return nil if relative_path.nil?

        File.join(tag_site(context).source, relative_path)
      end
    end

    class PageAssetTag < Liquid::Tag
      include TagHelpers

      def initialize(tag_name, markup, options)
        super
        @markup = markup
      end

      def render(context)
        # Split the markup into file name and opts.
        @type, @target, @rest, @params = parse_tag_markup(@markup, context)
        full_target_path = page_asset_relative_path(context, @target)
        return "" if full_target_path.nil? || full_target_path.empty?

        renderer = PageAsset::Renderer.new_by_type(
          type: @type,
          asset_path_arg: full_target_path,
          rest: @rest,
          params: @params
        )
        ren = renderer.render(context)

        <<~HTML
          <div class="page-asset-container">
            #{ren}
          </div>
        HTML
      end
    end
  end
end

Liquid::Template.register_tag("page_asset", Jekyll::PageAsset::PageAssetTag)
