# frozen_string_literal: true
module Jekyll
  module PageAsset
    class FountainRenderer < Renderer
      register_type 'fountain'

      def render(context)
        include_vars = build_include_vars(
          "script_text" => File.read(@target_asset_path)
        )
        render_template(context, include_vars)
      end
    end
  end
end
