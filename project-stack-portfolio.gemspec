# frozen_string_literal: true

require_relative "lib/project-stack-portfolio/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-project-stack-portfolio"
  spec.version       = ProjectStackPortfolio::VERSION
  spec.authors       = ["Alastair King"]
  spec.email         = ["ali@kinginterweb.com"]
  spec.summary       = "Retro portfolio theme for Jekyll"
  spec.description   = "Provides layouts, includes, styles, assets for a project portfolio theme."
  spec.homepage      = "https://example.com"
  spec.license       = "GPL-3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir[
    "lib/**/*",
    "_layouts/**/*",
    "_includes/**/*",
    "_sass/**/*",
    "assets/**/*",
    "_plugins/stack_row.rb",
    "LICENSE",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", ">= 4.0", "< 5.0"
  spec.add_runtime_dependency "jekyll-seo-tag", ">= 2.8", "< 3.0"
end
