# frozen_string_literal: true

require_relative "lib/rbs_examples_downloader"
require_relative "lib/rbs_inline_examples_downloader"
require_relative "lib/rbs_comments_stripper"
require_relative "lib/generate_plugins"

SOURCE_DIR = "source/plugins"
OUTPUT_DIR = "plugins"
RBS_EXAMPLES_PATH = "ruby-type-signature-skills/skills/generating-rbs/reference/rbs_examples"
RBS_INLINE_EXAMPLES_PATH = "ruby-type-signature-skills/skills/generating-rbs/generating-rbs-inline/reference/rbs_inline_examples"

task :generate do
  RbsExamplesDownloader.new(File.join(SOURCE_DIR, RBS_EXAMPLES_PATH)).call
  RbsCommentsStripper.new(File.join(SOURCE_DIR, RBS_EXAMPLES_PATH)).call
  RbsInlineExamplesDownloader.new(File.join(SOURCE_DIR, RBS_INLINE_EXAMPLES_PATH)).call
  GeneratePlugins.new(SOURCE_DIR, OUTPUT_DIR).call
end
