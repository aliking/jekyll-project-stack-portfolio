# frozen_string_literal: true

require "net/http"
require "base64"

module Jekyll
  module ProjectAsset
    class ProjectAssetTag < Liquid::Tag
      def initialize(tag_name, markup, options)
        super

        # Split the markup into file name and opts
        @filename, @rest = markup.split(' ', 2)
      end

      def get_full_asset_path(ctx)
        project_name = ctx.registers[:page].url.split('/').last
        asset_root = my_config = Jekyll.configuration['project_asset']['asset_root'].split('/')
        (asset_root << project_name << @filename).join('/')
      end

      def render(context) # rubocop:disable Metrics/PerceivedComplexity
        fullpath = get_full_asset_path(context)
        augmented_liquid = "{% picture #{fullpath} #{@rest} %}"
        Liquid::Template.parse(augmented_liquid).render(context)
      end
    end
  end
end

Liquid::Template.register_tag("project_asset", Jekyll::ProjectAsset::ProjectAssetTag)
