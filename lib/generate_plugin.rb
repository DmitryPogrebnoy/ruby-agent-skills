# frozen_string_literal: true

require "fileutils"
require_relative "http_client"

# Generates plugins from source directory
class GeneratePlugin
  SEPARATOR = "-" * 100

  def initialize(source_dir, output_dir)
    @source_dir = source_dir
    @output_dir = output_dir
  end

  def call
    clean_output
    copy_source
    convert_github_references
  end

  private

  def clean_output
    FileUtils.rm_rf(@output_dir)
    FileUtils.mkdir_p(@output_dir)
  end

  def copy_source
    FileUtils.cp_r(Dir.glob(File.join(@source_dir, "*")), @output_dir)
  end

  def convert_github_references
    Dir.glob(File.join(@output_dir, "**", "*.md")).each do |md_file|
      process_markdown_file(md_file)
    end
  end

  def process_markdown_file(md_file)
    content = File.read(md_file)
    skill_dir = File.dirname(md_file)
    modified = false

    content.gsub!(markdown_link_pattern) do |_match|
      link_text = Regexp.last_match(1)
      url = Regexp.last_match(2)

      reference = parse_github_url(url)
      download_reference(reference, skill_dir)
      modified = true

      puts "  Replaced: #{url} -> #{reference[:relative_path]}"
      puts SEPARATOR

      "[#{link_text}](#{reference[:relative_path]})"
    end

    content.gsub!(standalone_url_pattern) do |url|
      next url if url.include?("/tree/")

      reference = parse_github_url(url)
      download_reference(reference, skill_dir)
      modified = true

      puts "  Replaced: #{url} -> #{reference[:relative_path]}"
      puts SEPARATOR

      reference[:relative_path]
    end

    if modified
      File.write(md_file, content)
      puts "Updated: #{md_file}"
    end
  end

  def markdown_link_pattern
    %r{\[([^\]]+)\]\((https://github\.com/[^/]+/[^/]+/blob/[^/]+/[^\s)]+)\)}
  end

  def standalone_url_pattern
    %r{(?<!\()(https://github\.com/[^/]+/[^/]+/blob/[^/]+/[^\s)\]]+)}
  end

  def parse_github_url(url)
    pattern = %r{https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/([^\s)\]]+)}
    match = url.match(pattern)
    raise "Invalid GitHub URL: #{url}" unless match

    owner, repo, branch, path = match.captures
    path, fragment = extract_fragment(path)

    filename = File.basename(path)
    relative_path = "reference/#{filename}"
    relative_path += "##{fragment}" if fragment

    {
      raw_url: "https://raw.githubusercontent.com/#{owner}/#{repo}/#{branch}/#{path}",
      filename: filename,
      relative_path: relative_path
    }
  end

  def extract_fragment(path)
    if path.include?("#")
      path, fragment = path.split("#", 2)
      fragment = fragment.sub(/[.,;:!?]+$/, "")
    end
    path = path.sub(/[.,;:!?]+$/, "")
    [path, fragment]
  end

  def download_reference(reference, skill_dir)
    local_path = File.join(skill_dir, "reference", reference[:filename])

    puts "  Downloading: #{reference[:raw_url]}"
    content = HttpClient.download(reference[:raw_url])

    FileUtils.mkdir_p(File.dirname(local_path))
    File.write(local_path, content)
    puts "  Saved: #{local_path}"
  end
end
