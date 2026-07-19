# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "fileutils"

class SmokeTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  BUILD_DIR = File.join(ROOT, "tmp", "test_site")

  def test_strict_jekyll_build_and_html_proofer
    FileUtils.rm_rf(BUILD_DIR)

    build_cmd = [
      "bundle", "exec", "jekyll", "build",
      "--strict_front_matter",
      "--destination", BUILD_DIR
    ]

    build_output = run_command(build_cmd)
    assert build_output[:success], <<~MSG
      Strict Jekyll build failed.
      Command: #{build_output[:cmd]}
      Output:
      #{build_output[:output]}
    MSG

    proof_cmd = [
      "bundle", "exec", "htmlproofer", BUILD_DIR,
      "--disable-external", "true"
    ]

    proof_output = run_command(proof_cmd)
    assert proof_output[:success], <<~MSG
      html-proofer failed.
      Command: #{proof_output[:cmd]}
      Output:
      #{proof_output[:output]}
    MSG
  ensure
    FileUtils.rm_rf(BUILD_DIR)
  end

  private

  def run_command(cmd)
    stdout, stderr, status = Open3.capture3(*cmd, chdir: ROOT)

    {
      cmd: cmd.join(" "),
      success: status.success?,
      output: [stdout, stderr].join
    }
  end
end
