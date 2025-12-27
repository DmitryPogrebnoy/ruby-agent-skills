# frozen_string_literal: true

require_relative "lib/rbs_examples_downloader"
require_relative "lib/generate_plugin"

SOURCE_DIR = "source/plugins"
OUTPUT_DIR = "plugins"
RBS_EXAMPLES_PATH = "ruby-type-signature-skills/skills/generating-rbs/reference/rbs_examples"

task :generate do
  RbsExamplesDownloader.new(File.join(SOURCE_DIR, RBS_EXAMPLES_PATH)).call
  GeneratePlugin.new(SOURCE_DIR, OUTPUT_DIR).call
end
