# frozen_string_literal: true

require "fileutils"
require "stringio"
require "rubygems/package"
require "zlib"
require_relative "http_client"

# Downloads RBS examples from ruby/rbs repository
class RbsExamplesDownloader
  REPO = "ruby/rbs"
  BRANCH = "master"

  def initialize(dest_dir)
    @dest_dir = dest_dir
  end

  def call
    puts "\n=== Downloading RBS rbs_inline_examples from #{REPO} ==="
    puts "Downloading to: #{@dest_dir}"

    prepare_destination
    tarball_data = download_tarball
    extract_rbs_files(tarball_data)
    create_structure_files
  end

  private

  def prepare_destination
    FileUtils.rm_rf(@dest_dir)
    FileUtils.mkdir_p(@dest_dir)
  end

  def download_tarball
    url = "https://github.com/#{REPO}/archive/refs/heads/#{BRANCH}.tar.gz"
    data = HttpClient.download(url, follow_redirects: true)
    puts "  Downloaded #{data.bytesize} bytes"
    data
  end

  def extract_rbs_files(tarball_data)
    puts "  Extracting RBS files..."

    io = StringIO.new(tarball_data)
    gz = Zlib::GzipReader.new(io)
    tar = Gem::Package::TarReader.new(gz)

    tar.each do |entry|
      next unless entry.file?
      next unless entry.full_name.end_with?(".rbs")

      relative_path = extract_relative_path(entry.full_name)
      next unless relative_path
      next unless relative_path.start_with?("core/") || relative_path.start_with?("stdlib/")

      save_entry(entry, relative_path)
    end

    tar.close
    gz.close
  end

  def extract_relative_path(full_name)
    parts = full_name.split("/", 2)
    return nil unless parts.length == 2

    path = parts[1]

    # Remove version folder from stdlib paths (e.g., stdlib/json/0/file.rbs -> stdlib/json/file.rbs)
    if path.start_with?("stdlib/")
      path = path.sub(%r{^(stdlib/[^/]+)/\d+/}, '\1/')
    end

    path
  end

  def save_entry(entry, relative_path)
    dest_path = File.join(@dest_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(dest_path))
    File.open(dest_path, "wb") { |f| f.write(entry.read) }
  end

  def create_structure_files
    create_main_structure
    create_core_structure
    create_stdlib_structure
  end

  def create_main_structure
    path = File.join(@dest_dir, "STRUCTURE.md")
    content = <<~STRUCTURE
      # RBS Examples

      RBS type signatures from [ruby/rbs](https://github.com/ruby/rbs) repository.

      - [core/](core/STRUCTURE.md) - Ruby core library signatures
      - [stdlib/](stdlib/STRUCTURE.md) - Ruby standard library signatures
    STRUCTURE
    File.write(path, content)
  end

  def create_core_structure
    path = File.join(@dest_dir, "core", "STRUCTURE.md")
    files = list_files("core")
    content = <<~STRUCTURE
      # Core RBS Signatures

      Type signatures for Ruby built-in classes and modules.

      #{files.map { |f| "- [#{f}](#{f})" }.join("\n")}
    STRUCTURE
    File.write(path, content)
  end

  def create_stdlib_structure
    path = File.join(@dest_dir, "stdlib", "STRUCTURE.md")
    dirs = list_directories("stdlib")
    content = <<~STRUCTURE
      # Stdlib RBS Signatures

      Type signatures for Ruby standard library.

      #{dirs.map { |d| "- [#{d}/](#{d}/)" }.join("\n")}
    STRUCTURE
    File.write(path, content)
  end

  def list_files(subdir)
    dir = File.join(@dest_dir, subdir)
    return [] unless File.directory?(dir)

    Dir.children(dir).select { |f| File.file?(File.join(dir, f)) && f.end_with?(".rbs") }.sort
  end

  def list_directories(subdir)
    dir = File.join(@dest_dir, subdir)
    return [] unless File.directory?(dir)

    Dir.children(dir).select { |f| File.directory?(File.join(dir, f)) }.sort
  end
end
