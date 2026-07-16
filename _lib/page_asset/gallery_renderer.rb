# frozen_string_literal: true

require "cgi"

module Jekyll
  module PageAsset
    class GalleryRenderer < Renderer
      register_type 'gallery'

      SUPPORTED_IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .webp .avif .gif].freeze

      def render(context)
        return "" if @target_asset_paths.empty?

        gallery_asset_root = @asset_path_arg
        images = discover_images(@target_asset_paths)

        return empty_state_html(@asset_path_arg) if images.empty?

        thumbnails = images.each_with_index.map do |filename, index|
          asset_path = File.join(gallery_asset_root, filename)
          src = "/#{asset_path}"
          alt = alt_text_for(filename, index)
          picture_tag = render_picture(context, asset_path)

          <<~HTML
            <button
              class="gallery-thumb"
              type="button"
              data-gallery-thumb="true"
              data-gallery-id="#{html_escape(@asset_path_arg)}"
              data-gallery-index="#{index}"
              data-gallery-src="#{html_escape(src)}"
              data-gallery-alt="#{html_escape(alt)}"
              aria-label="Open image #{index + 1}">
              #{picture_tag}
            </button>
          HTML
        end

        <<~HTML
          <section class="project-gallery" data-gallery="#{html_escape(@asset_path_arg)}" aria-label="Image gallery">
            <div class="project-gallery-grid">
              #{thumbnails.join("\n")}
            </div>
          </section>
        HTML
      end

      private

      def discover_images(paths)
        paths.select { |entry| SUPPORTED_IMAGE_EXTENSIONS.include?(File.extname(entry).downcase) }
           .sort_by(&:downcase)
      end

      def render_picture(context, path)
        escaped_path = path.gsub('"', '\\"')
        liquid = "{% picture \"#{escaped_path}\" %}"
        Liquid::Template.parse(liquid).render(context)
      end

      def alt_text_for(filename, index)
        stem = File.basename(filename, File.extname(filename)).tr("_-", " ").strip
        return "Gallery image #{index + 1}" if stem.empty?

        stem.gsub(/\s+/, " ")
      end

      def empty_state_html(gallery_id)
        <<~HTML
          <section class="project-gallery" data-gallery="#{html_escape(gallery_id)}" aria-label="Image gallery">
            <p class="project-gallery-empty">No gallery images found.</p>
          </section>
        HTML
      end

      def html_escape(value)
        CGI.escape_html(value.to_s)
      end
    end
  end
end

