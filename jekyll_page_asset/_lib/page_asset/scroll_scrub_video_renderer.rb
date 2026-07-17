# frozen_string_literal: true

module Jekyll
  module PageAsset
    class ScrollScrubVideoRenderer < Renderer
      register_type 'scroll_scrub_video'

      DEFAULTS = {
        "pixels_per_second" => 50,
        "sticky_top" => 120
      }.freeze

      def render(context)
        include_vars = build_include_vars({
          "video_path"        => @target_asset_path,
          "pixels_per_second" => (@params["pixels_per_second"] || DEFAULTS["pixels_per_second"]).to_i,
          "sticky_top"        => (@params["sticky_top"] || DEFAULTS["sticky_top"]).to_i
        })

        render_template(context, include_vars)
      end
    end
  end
end
