# frozen_string_literal: true

require 'cgi'

# Registers the `stack_row` Liquid tag.
#
# Usage:
#   {% stack_row project=project current_url=include.current_url %}
#   {% stack_row tape project=project current_url=include.current_url %}
#   {% stack_row notebook project=project current_url=include.current_url %}
#   {% stack_row cd project=project current_url=include.current_url %}
#
# The row type can be passed explicitly or inferred from the project's `type`
# front matter. Supported types: tape/vhs, notebook, and cd.
# Named parameters are resolved as Liquid variables from the calling context.
#
# Transform limits and seed are read from _config.yml:
#   stack_transform:
#     seed: 42
#     translate_max: 20

module Jekyll
  class StackRowTag < Liquid::Tag
    STACK_SVG_FILES = {
      'tape' => 'tape.svg',
      'vhs' => 'tape.svg',
      'notebook' => 'notebook.svg',
      'cd' => 'cd.svg'
    }.freeze

    def initialize(tag_name, markup, tokens)
      super
      parts = markup.strip.split(/\s+/, 2)

      if parts[0].to_s.include?('=')
        @row_type = ''
        @raw_params = markup.to_s
      else
        @row_type = parts[0].to_s.strip
        @raw_params = parts[1].to_s
      end
    end

    def render(context)
      params = {}
      @raw_params.scan(/(\w+)=([\w.]+)/) do |key, val|
        params[key] = context[val]
      end

      project     = params['project']
      current_url = params['current_url'].to_s
      return '' if project.nil?

      site        = context.registers[:site]
      cfg         = Jekyll.configuration.dig("project-stack-portfolio", "stack_transform") || {}
      seed        = cfg.fetch('seed', 42).to_i
      tx_max      = cfg.fetch('translate_max', 20).to_f

      project_url = project.url.to_s
      translate_x = seeded_rand("#{project_url}tx", seed, -tx_max, tx_max)

      is_current  = current_url.include?(project_url)
      link_class  = is_current ? 'project-stack-item disabled' : 'project-stack-item'
      style_class = project['stack_style'].to_s.strip
      stack_type  = normalize_stack_type(params['type'] || @row_type || project['type'])
      art_class   = ['project-stack-item-art', style_class].reject(&:empty?).join(' ')
      row_class   = ['project-stack-item-row', "project-stack-item-row--#{stack_type}"].join(' ')
      link_class  = [link_class, "project-stack-item--#{stack_type}"].join(' ')
      baseurl     = site.config['baseurl'].to_s
      href        = "#{baseurl}#{project_url}"
      title       = CGI.escape_html(project['title'].to_s.upcase)
      stack_svg   = read_stack_svg(site, stack_type)

      <<~HTML
        <div class="#{row_class}">
          <a class="#{link_class}" style="transform: translateX(#{translate_x}px);" href="#{href}">
            <div class="#{art_class}" aria-hidden="true">
              #{stack_svg}
            </div>
            <div class="project-stack-item-label" aria-hidden="true">
              <svg viewBox="0 0 500 50" width="100%" role="presentation" focusable="false">
                <text x="0" y="40" font-size="40" font-weight="700" textLength="100%" lengthAdjust="spacingAndGlyphs">#{title}</text>
              </svg>
            </div>
          </a>
        </div>
      HTML
    end

    private

    def normalize_stack_type(value)
      case value.to_s.downcase.strip
      when 'notebook'
        'notebook'
      when 'cd'
        'cd'
      when 'vhs', 'tape'
        'tape'
      else
        'tape'
      end
    end

    # Deterministic pseudo-random float in [min, max] keyed on input string + seed.
    # Byte-based hash is stable across Ruby versions (String#hash is randomized).
    def seeded_rand(input, seed, min, max)
      stable = input.bytes.each_with_index.inject(0) { |acc, (b, i)| acc + b * (31**i) }
      rng    = Random.new(seed + stable)
      (rng.rand * (max - min) + min).round(2)
    end

    def read_stack_svg(site, stack_type)
      svg_file = STACK_SVG_FILES.fetch(stack_type, STACK_SVG_FILES['tape'])
      site_svg_path = File.join(site.source, '_includes', 'components', 'sidebar', svg_file)
      return File.read(site_svg_path).strip if File.exist?(site_svg_path)

      gem_svg_path = File.expand_path("../_includes/components/sidebar/#{svg_file}", __dir__)
      return File.read(gem_svg_path).strip if File.exist?(gem_svg_path)

      ''
    rescue Errno::ENOENT
      ''
    end
  end
end

Liquid::Template.register_tag('stack_row', Jekyll::StackRowTag)
