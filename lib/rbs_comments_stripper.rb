# frozen_string_literal: true

# Strips comments from RBS files
class RbsCommentsStripper
  def initialize(dir)
    @dir = dir
  end

  def call
    puts "\n=== Stripping comments from RBS files ==="

    files = Dir.glob(File.join(@dir, "**/*.rbs"))
    files.each { |file| strip_file(file) }

    puts "  Processed #{files.size} files"
  end

  private

  def strip_file(file)
    lines = File.readlines(file)
    result = []
    prev_blank = false

    lines.each do |line|
      next if line.strip.start_with?("#")

      if line.strip.empty?
        result << line unless prev_blank
        prev_blank = true
      else
        result << line
        prev_blank = false
      end
    end

    result.shift while result.first&.strip&.empty?
    result.pop while result.last&.strip&.empty?

    File.write(file, result.join)
  end
end
