# frozen_string_literal: true

require "net/http"
require "base64"

module Jekyll
  module Fountain
    class FountainTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super

        # Split the markup into file name and opts
        @filename, @rest = markup.split(' ', 2)
      end

      def get_full_asset_path(ctx)
        project_name = ctx.registers[:page].url.split('/').last
        asset_root = Jekyll.configuration['project_asset']['asset_root'].split('/')
        (asset_root << project_name << @filename).join('/')
      end

      def render(context)
        site = context.registers[:site]
        include_path = File.join(site.source, "_includes", "fountain.html")

        unless File.exist?(include_path)
          raise IOError, "fountain: include file not found at #{include_path}"
        end

        full_script_path = get_full_asset_path(context)
        script_text = File.read(full_script_path)

        template = Liquid::Template.parse(File.read(include_path))

        context["script_text"] = script_text
        template.render(context)
      end
    end
  end
end


Liquid::Template.register_tag("fountain", Jekyll::Fountain::FountainTag)
