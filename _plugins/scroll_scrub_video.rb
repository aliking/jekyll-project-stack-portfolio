# frozen_string_literal: true

module Jekyll
  class ScrollScrubVideoTag < Liquid::Tag
    DEFAULTS = {
      "pixels_per_second" => 50,
      "sticky_top" => 120
    }.freeze

    def initialize(tag_name, markup, options)
      super
      @params = {}
      markup.scan(/(\w+)=(?:'([^']*)'|"([^"]*)"|(\S+))/) do |key, sq, dq, bare|
        @params[key] = sq || dq || bare
      end

      raise SyntaxError, "#{tag_name}: 'video_path' is required" unless @params.key?("video_path")
    end

    def render(context)
      site = context.registers[:site]
      include_path = File.join(site.source, "_includes", "scroll_scrub_video.html")

      unless File.exist?(include_path)
        raise IOError, "scroll_scrub_video: include file not found at #{include_path}"
      end

      template = Liquid::Template.parse(File.read(include_path))

      include_vars = {
        "video_path"        => @params["video_path"],
        "pixels_per_second" => (@params["pixels_per_second"] || DEFAULTS["pixels_per_second"]).to_i,
        "sticky_top"        => (@params["sticky_top"] || DEFAULTS["sticky_top"]).to_i
      }

      context.stack do
        context["include"] = include_vars
        template.render(context)
      end
    end
  end
end

Liquid::Template.register_tag("scroll_scrub_video", Jekyll::ScrollScrubVideoTag)
