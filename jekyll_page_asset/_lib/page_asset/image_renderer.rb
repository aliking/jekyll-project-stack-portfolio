# frozen_string_literal: true

require "net/http"
require "base64"

module Jekyll
  module PageAsset
    class ImageRenderer < Renderer
      register_type 'image'

      def render(context)
        augmented_liquid = "{% picture #{@target_asset_path} #{@rest} %}"
        Liquid::Template.parse(augmented_liquid).render(context)
      end
    end
  end
end

