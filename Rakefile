# frozen_string_literal: true

require "fileutils"
require "net/http"
require "uri"
require "openssl"

SOURCE_DIR = "source/plugins"
OUTPUT_DIR = "plugins"
SEPARATOR = '-' * 100

task :generate do
  generate_plugins(SOURCE_DIR, OUTPUT_DIR)
end

def generate_plugins(source_dir, output_dir)
  # Clean and recreate the output directory
  FileUtils.rm_rf(output_dir)
  FileUtils.mkdir_p(output_dir)

  # Copy source to output
  FileUtils.cp_r(Dir.glob(File.join(source_dir, "*")), output_dir)

  # Process all Markdown files in output
  convert_md_references_to_local_files(output_dir)
end


def convert_md_references_to_local_files(generated_skill_dir)
  Dir.glob(File.join(generated_skill_dir, "**", "*.md")).each do |md_file|
    convert_md_references_to_local_files_for_single_file(md_file)
  end
end

def convert_md_references_to_local_files_for_single_file(md_file)
  content = File.read(md_file)
  skill_dir = File.dirname(md_file)
  modified = false

  # Find GitHub blob URLs in markdown links: [text](https://github.com/.../blob/...)
  markdown_link_pattern = %r{\[([^\]]+)\]\((https://github\.com/[^/]+/[^/]+/blob/[^/]+/[^\s)]+)\)}

  content.gsub!(markdown_link_pattern) do |_match|
    link_text = Regexp.last_match(1)
    url = Regexp.last_match(2)

    reference = github_url_to_local_reference(url)
    local_path = File.join(skill_dir, "reference", reference[:filename])

    download_file(reference[:raw_url], local_path)
    modified = true
    puts "  Replaced: #{url} -> #{reference[:relative_path]}"
    puts SEPARATOR
    "[#{link_text}](#{reference[:relative_path]})"
  end

  # Find standalone GitHub blob URLs (not in markdown links, skip tree URLs)
  github_blob_pattern = %r{(?<!\()(https://github\.com/[^/]+/[^/]+/blob/[^/]+/[^\s)\]]+)}

  content.gsub!(github_blob_pattern) do |url|
    next url if url.include?("/tree/")

    reference = github_url_to_local_reference(url)
    local_path = File.join(skill_dir, "reference", reference[:filename])

    download_file(reference[:raw_url], local_path)
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

def github_url_to_local_reference(url)
  pattern = %r{https://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/([^\s)\]]+)}
  match = url.match(pattern)
  raise "Invalid GitHub URL: #{url}" unless match

  owner = match[1]
  repo = match[2]
  branch = match[3]
  path = match[4]

  # Extract fragment if present and strip trailing punctuation
  fragment = nil
  if path.include?("#")
    path, fragment = path.split("#", 2)
    fragment = fragment.sub(/[.,;:!?]+$/, "")
  end
  path = path.sub(/[.,;:!?]+$/, "")

  filename = File.basename(path)
  relative_path = "reference/#{filename}"
  relative_path += "##{fragment}" if fragment

  {
    raw_url: "https://raw.githubusercontent.com/#{owner}/#{repo}/#{branch}/#{path}",
    filename: filename,
    relative_path: relative_path
  }
end

def download_file(url, local_path)
  puts "  Downloading: #{url}"

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)

  unless response.is_a?(Net::HTTPSuccess)
    raise "Failed to download: #{url} (HTTP #{response.code})"
  end

  FileUtils.mkdir_p(File.dirname(local_path))
  File.write(local_path, response.body)
  puts "  Saved: #{local_path}"
end
