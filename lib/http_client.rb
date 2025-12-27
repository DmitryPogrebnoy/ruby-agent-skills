# frozen_string_literal: true

require "net/http"
require "uri"
require "openssl"

# HTTP client for downloading files
class HttpClient
  def self.download(url, follow_redirects: false)
    uri = URI.parse(url)
    response = request(uri)

    if follow_redirects
      while response.is_a?(Net::HTTPRedirection)
        uri = URI.parse(response["location"])
        response = request(uri)
      end
    end

    raise "Failed to download: #{url} (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end

  def self.request(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "ruby-agent-skills-rake"
    http.request(request)
  end
end
