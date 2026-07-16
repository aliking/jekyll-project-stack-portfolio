# frozen_string_literal: true

require "cgi"

module Jekyll
  module PageAsset
    class VideoRenderer < Renderer
      register_type "video"

      DISPLAY_BACKGROUND = "background"
      DISPLAY_FOREGROUND = "foreground"

      def render(context)
        video_path =  @target_asset_path

        display = normalized_display(@params["display"])
        classes = display == DISPLAY_BACKGROUND ? "background-video" : "foreground-video"
        playback_attrs = display == DISPLAY_BACKGROUND ? "autoplay muted loop playsinline" : "controls playsinline"

        <<~HTML
          <video #{playback_attrs} preload="auto" class="#{classes}">
            <source src="/#{html_escape(video_path)}" type="#{html_escape(mime_type_for(video_path))}">
            Your browser does not support the video tag.
          </video>
        HTML
      end

      private

      def normalized_display(value)
        normalized = value.to_s.strip.downcase
        return DISPLAY_BACKGROUND if normalized == DISPLAY_BACKGROUND

        DISPLAY_FOREGROUND
      end

      def mime_type_for(path)
        case File.extname(path).downcase
        when ".webm"
          "video/webm"
        when ".ogv"
          "video/ogg"
        else
          "video/mp4"
        end
      end

      def html_escape(value)
        CGI.escape_html(value.to_s)
      end
    end
  end
end
