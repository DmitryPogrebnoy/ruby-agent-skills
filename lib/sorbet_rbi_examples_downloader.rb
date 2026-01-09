# frozen_string_literal: true

require "fileutils"
require "stringio"
require "rubygems/package"
require "zlib"
require_relative "http_client"

# Downloads Sorbet RBI examples from gems that include RBI files
class SorbetRbiExamplesDownloader
  GEMS = {
    "stripe-ruby" => { repo: "stripe/stripe-ruby", branch: "master", rbi_path: "rbi", lib_path: "lib" }
  }.freeze

  def initialize(dest_dir)
    @dest_dir = dest_dir
  end

  def call
    puts "\n=== Downloading Sorbet RBI examples ==="
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
    extract_files(tarball_data, config[:rbi_path], config[:lib_path], gem_dest)

    puts "    Done: #{name}"
  end

  def download_tarball(repo, branch)
    url = "https://github.com/#{repo}/archive/refs/heads/#{branch}.tar.gz"
    data = HttpClient.download(url, follow_redirects: true)
    puts "    Downloaded #{data.bytesize} bytes"
    data
  end

  def extract_files(tarball_data, rbi_path, lib_path, dest_dir)
    io = StringIO.new(tarball_data)
    gz = Zlib::GzipReader.new(io)
    tar = Gem::Package::TarReader.new(gz)

    prefix = nil
    rbi_count = 0
    rb_count = 0

    tar.each do |entry|
      # Skip pax headers and find actual root folder
      if prefix.nil? && entry.full_name.include?("/") && !entry.full_name.start_with?("pax")
        prefix = entry.full_name.split("/").first
      end

      next unless entry.file?
      next if prefix.nil?

      # Skip very large files (> 500KB) to keep examples manageable
      next if entry.size > 500_000

      # Extract RBI files into rbi/ subdirectory
      if entry.full_name.end_with?(".rbi")
        relative_path = extract_path(entry.full_name, prefix, rbi_path)
        if relative_path
          save_entry(entry, dest_dir, "rbi/#{relative_path}")
          rbi_count += 1
        end
      end

      # Extract Ruby files from lib/ into lib/ subdirectory
      if entry.full_name.end_with?(".rb") && lib_path
        relative_path = extract_path(entry.full_name, prefix, lib_path)
        if relative_path
          save_entry(entry, dest_dir, "lib/#{relative_path}")
          rb_count += 1
        end
      end
    end

    puts "    Extracted #{rbi_count} RBI files, #{rb_count} Ruby files"

    tar.close
    gz.close
  end

  def extract_path(full_name, prefix, source_path)
    # Full expected prefix (e.g., "stripe-ruby-master/rbi/")
    full_prefix = "#{prefix}/#{source_path}/"

    # Check if it's under the source path
    return nil unless full_name.start_with?(full_prefix)

    # Return path relative to source_path
    full_name.sub(full_prefix, "")
  end

  def save_entry(entry, dest_dir, relative_path)
    dest_path = File.join(dest_dir, relative_path)
    FileUtils.mkdir_p(File.dirname(dest_path))
    File.open(dest_path, "wb") { |f| f.write(entry.read) }
  end

  def create_structure_file
    path = File.join(@dest_dir, "STRUCTURE.md")
    content = <<~'STRUCTURE'
      # Sorbet RBI References

      Real-world RBI files from gems that include Sorbet type definitions.

      ## Contents

      - [RBI File Conventions](#rbi-file-conventions)
      - [stripe-ruby Examples](#stripe-ruby-examples)
        - [Directory Structure](#stripe-ruby-directory-structure)
        - [Resources](#resources)
        - [Services](#services)
        - [Params](#params)
        - [Key Patterns](#key-patterns)
      - [External Resources](#external-resources)

      ## RBI File Conventions

      ### Directory Structure

      ```
      rbi/
      ├── gem_name.rbi      # Main gem RBI file
      └── gem_name/
          ├── resources/    # Resource type definitions
          ├── services/     # Service type definitions
          └── params/       # Parameter type definitions
      ```

      ### RBI Syntax Key Points

      1. **Empty method bodies** - use `; end` or just `end`
      2. **Typed sigils** - use `# typed: true` or `# typed: strict`
      3. **No implementation** - only type declarations and structure

      ## stripe-ruby Examples

      Source: https://github.com/stripe/stripe-ruby (MIT License)

      ### stripe-ruby Directory Structure

      ```
      stripe-ruby/
      ├── rbi/                      # Type definitions
      │   └── stripe/
      │       ├── resources/        # 96 resource type definitions
      │       │   ├── customer.rbi
      │       │   └── ...
      │       ├── services/         # 115 service type definitions
      │       │   ├── customer_service.rbi
      │       │   └── ...
      │       └── params/           # 324 parameter type definitions
      │           ├── customer_create_params.rbi
      │           └── ...
      └── lib/                      # Ruby source
          └── stripe/
              ├── resources/
              │   ├── customer.rb
              │   └── ...
              ├── services/
              │   ├── customer_service.rb
              │   └── ...
              └── ...
      ```

      ### Resources

      Resource files define API response types with nested classes:

      **Pattern**: [rbi/stripe/resources/customer.rbi](stripe-ruby/rbi/stripe/resources/customer.rbi)
      ```ruby
      # typed: true
      module Stripe
        class Customer < APIResource
          # Nested class for address
          class Address < ::Stripe::StripeObject
            sig { returns(T.nilable(String)) }
            def city; end
            sig { returns(T.nilable(String)) }
            def country; end
          end

          # Top-level attributes
          sig { returns(T.nilable(Address)) }
          def address; end
          sig { returns(T.nilable(Integer)) }
          def balance; end
          sig { returns(T::Boolean) }
          def livemode; end

          # API methods
          sig {
            params(params: T.any(::Stripe::CustomerCreateParams, T::Hash[T.untyped, T.untyped]), opts: T.untyped)
              .returns(::Stripe::Customer)
          }
          def self.create(params = {}, opts = {}); end
        end
      end
      ```

      ### Services

      Service files define API operation methods:

      **Pattern**: [rbi/stripe/services/customer_service.rbi](stripe-ruby/rbi/stripe/services/customer_service.rbi)
      ```ruby
      # typed: true
      module Stripe
        class CustomerService < StripeService
          attr_reader :balance_transactions
          attr_reader :payment_methods

          sig {
            params(params: T.any(::Stripe::CustomerCreateParams, T::Hash[T.untyped, T.untyped]), opts: T.untyped)
              .returns(::Stripe::Customer)
          }
          def create(params = {}, opts = {}); end

          sig {
            params(customer: String, params: T.any(::Stripe::CustomerRetrieveParams, T::Hash[T.untyped, T.untyped]), opts: T.untyped)
              .returns(::Stripe::Customer)
          }
          def retrieve(customer, params = {}, opts = {}); end
        end
      end
      ```

      ### Params

      Params files define typed request parameters with getters/setters:

      **Pattern**: [rbi/stripe/params/customer_create_params.rbi](stripe-ruby/rbi/stripe/params/customer_create_params.rbi)
      ```ruby
      # typed: true
      module Stripe
        class CustomerCreateParams < ::Stripe::RequestParams
          class Address < ::Stripe::RequestParams
            sig { returns(T.nilable(String)) }
            def city; end
            sig { params(_city: T.nilable(String)).returns(T.nilable(String)) }
            def city=(_city); end

            sig { params(city: T.nilable(String), country: T.nilable(String)).void }
            def initialize(city: nil, country: nil); end
          end

          sig { returns(T.nilable(CustomerCreateParams::Address)) }
          def address; end
        end
      end
      ```

      ### Key Patterns

      1. **Deeply Nested Classes** - Resource types use nested classes for complex objects
         - See: [customer.rbi](stripe-ruby/rbi/stripe/resources/customer.rbi) with `Address`, `InvoiceSettings`, `Shipping`, `Tax`

      2. **Union Types with `T.any`** - For polymorphic fields
         ```ruby
         sig { returns(T.nilable(T.any(String, ::Stripe::PaymentMethod))) }
         def default_payment_method; end
         ```

      3. **Multi-line Signatures** - For methods with many parameters
         ```ruby
         sig {
           params(params: T.any(::Stripe::CustomerCreateParams, T::Hash[T.untyped, T.untyped]), opts: T.untyped)
             .returns(::Stripe::Customer)
         }
         def create(params = {}, opts = {}); end
         ```

      4. **Collection Types** - Arrays and hashes with typed elements
         ```ruby
         sig { returns(T.nilable(T::Array[CustomField])) }
         def custom_fields; end

         sig { returns(T.nilable(T::Hash[String, Integer])) }
         def invoice_credit_balance; end
         ```

      5. **Boolean Type** - Using `T::Boolean`
         ```ruby
         sig { returns(T::Boolean) }
         def livemode; end
         ```

      6. **Instance and Class Methods** - Both defined for API operations
         ```ruby
         sig { params(params: T.any(...)).returns(::Stripe::Customer) }
         def self.create(params = {}, opts = {}); end

         sig { params(params: T.any(...)).returns(::Stripe::Customer) }
         def delete(params = {}, opts = {}); end
         ```

      ## External Resources

      - [Sorbet RBI docs](https://sorbet.org/docs/rbi) - Official RBI documentation
    STRUCTURE
    File.write(path, content)
  end
end
