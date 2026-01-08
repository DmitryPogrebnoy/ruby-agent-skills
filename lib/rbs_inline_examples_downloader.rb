# frozen_string_literal: true

require "fileutils"
require "stringio"
require "rubygems/package"
require "zlib"
require_relative "http_client"

# Downloads rbs-inline examples from gems that use rbs-inline annotations
class RbsInlineExamplesDownloader
  GEMS = {
    "zeitwerk" => { repo: "fxn/zeitwerk", branch: "main", lib_path: "lib" }
  }.freeze

  def initialize(dest_dir)
    @dest_dir = dest_dir
  end

  def call
    puts "\n=== Downloading rbs-inline rbs_inline_examples ==="
    puts "Downloading to: #{@dest_dir}"

    FileUtils.mkdir_p(@dest_dir)

    GEMS.each do |name, config|
      download_gem(name, config)
    end

    create_structure_file
  end

  private

  def download_gem(name, config)
    puts "  Downloading #{name} from #{config[:repo]}..."

    gem_dest = File.join(@dest_dir, name)
    FileUtils.rm_rf(gem_dest)
    FileUtils.mkdir_p(gem_dest)

    tarball_data = download_tarball(config[:repo], config[:branch])
    extract_ruby_files(tarball_data, config[:lib_path], gem_dest)

    puts "    Done: #{name}"
  end

  def download_tarball(repo, branch)
    url = "https://github.com/#{repo}/archive/refs/heads/#{branch}.tar.gz"
    data = HttpClient.download(url, follow_redirects: true)
    puts "    Downloaded #{data.bytesize} bytes"
    data
  end

  def extract_ruby_files(tarball_data, lib_path, dest_dir)
    io = StringIO.new(tarball_data)
    gz = Zlib::GzipReader.new(io)
    tar = Gem::Package::TarReader.new(gz)

    prefix = nil
    tar.each do |entry|
      # Skip pax headers and find actual root folder
      if prefix.nil? && entry.full_name.include?("/") && !entry.full_name.start_with?("pax")
        prefix = entry.full_name.split("/").first
      end

      next unless entry.file?
      next unless entry.full_name.end_with?(".rb")
      next if prefix.nil?

      # Extract path relative to lib/
      relative_path = extract_lib_path(entry.full_name, prefix, lib_path)
      next unless relative_path

      save_entry(entry, dest_dir, relative_path)
    end

    tar.close
    gz.close
  end

  def extract_lib_path(full_name, prefix, lib_path)
    # Full expected prefix (e.g., "zeitwerk-main/lib/")
    full_prefix = "#{prefix}/#{lib_path}/"

    # Check if it's under the lib path
    return nil unless full_name.start_with?(full_prefix)

    # Return path relative to lib/
    full_name.sub(full_prefix, "")
  end

  def save_entry(entry, dest_dir, relative_path)
    dest_path = File.join(dest_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(dest_path))
    File.open(dest_path, "wb") { |f| f.write(entry.read) }
  end

  def create_structure_file
    path = File.join(@dest_dir, "STRUCTURE.md")
    content = <<~STRUCTURE
      # RBS-Inline Examples

      Ruby gems that use rbs-inline type annotations as real-world references.

      #{GEMS.keys.map { |name| "- [#{name}/](#{name}/) - https://github.com/#{GEMS[name][:repo]}" }.join("\n")}
    STRUCTURE
    File.write(path, content)
  end
end
