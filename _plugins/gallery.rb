# frozen_string_literal: true

require "cgi"

module Jekyll
  module Gallery
    class GalleryTag < Liquid::Tag
      SUPPORTED_IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .webp .avif .gif].freeze

      def initialize(tag_name, markup, options)
        super
        @gallery_id = markup.to_s.strip
      end

      def render(context)
        return "" if @gallery_id.empty?

        site = context.registers[:site]
        page = context.registers[:page]

        project_name = project_slug_from_page(page)
        return "" if project_name.nil? || project_name.empty?

        asset_root = Jekyll.configuration.dig("project_asset", "asset_root") || "assets/project_media"
        gallery_asset_root = File.join(asset_root, project_name, @gallery_id)
        source_directory = File.join(site.source, gallery_asset_root)

        images = discover_images(source_directory)

        return empty_state_html(@gallery_id) if images.empty?

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
              data-gallery-id="#{html_escape(@gallery_id)}"
              data-gallery-index="#{index}"
              data-gallery-src="#{html_escape(src)}"
              data-gallery-alt="#{html_escape(alt)}"
              aria-label="Open image #{index + 1}">
              #{picture_tag}
            </button>
          HTML
        end

        <<~HTML
          <section class="project-gallery" data-gallery="#{html_escape(@gallery_id)}" aria-label="Image gallery">
            <div class="project-gallery-grid">
              #{thumbnails.join("\n")}
            </div>
          </section>
        HTML
      end

      private

      def discover_images(path)
        return [] unless Dir.exist?(path)

        Dir.children(path)
           .select { |entry| File.file?(File.join(path, entry)) }
           .select { |entry| SUPPORTED_IMAGE_EXTENSIONS.include?(File.extname(entry).downcase) }
           .sort_by(&:downcase)
      end

      def project_slug_from_page(page)
        page_url = page["url"] || page.url
        page_url.to_s.split("/").reject(&:empty?).last
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

Liquid::Template.register_tag("gallery", Jekyll::Gallery::GalleryTag)
