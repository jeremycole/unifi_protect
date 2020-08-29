# frozen_string_literal: true

require 'net/http'
require 'json'

module UnifiProtect
  class API
    class RefreshBearerTokenError < StandardError; end
    class RequestError < StandardError; end

    DownloadedFile = Struct.new(:file, :size, keyword_init: true)

    def initialize(host: nil, port: 7443, username: nil, password: nil, download_path: nil)
      @host = host
      @port = port
      @username = username
      @password = password
      @download_path = download_path
    end

    def to_s
      "#<#{self.class.name} base_uri=#{base_uri.to_s.inspect} username=#{@username.inspect}>"
    end

    def inspect
      to_s
    end

    def base_uri
      URI::HTTPS.build(host: @host, port: @port, path: '/api/')
    end

    def uri(path:, query: nil)
      uri = URI.join(base_uri, path)
      uri.query = query if query

      uri
    end

    def new_http_client
      http_client = Net::HTTP.new(base_uri.host, base_uri.port)
      http_client.use_ssl = true
      http_client.verify_mode = OpenSSL::SSL::VERIFY_NONE

      http_client
    end

    def http_client
      @http_client ||= new_http_client
    end

    def http_post_with_username_password(uri)
      headers = {
        'Content-Type' => 'application/json',
      }
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = { username: @username, password: @password }.to_json

      request
    end

    def http_post_with_bearer_token(uri, body: nil)
      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer ' + bearer_token,
      }
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body

      request
    end

    def http_get_with_bearer_token(uri)
      headers = {
        'Authorization' => 'Bearer ' + bearer_token,
      }
      Net::HTTP::Get.new(uri.request_uri, headers)
    end

    def http_request_with_bearer_token(uri, method: :get, body: nil)
      return http_get_with_bearer_token(uri) if method == :get
      return http_post_with_bearer_token(uri, body: body) if method == :post

      nil
    end

    def refresh_bearer_token
      response = http_client.request(http_post_with_username_password(uri(path: 'auth')))

      raise RefreshBearerTokenError, "#{response.code} #{response.msg}: #{response.body}" unless response.code == '200'

      @bearer_token = response['Authorization']
    end

    def bearer_token
      @bearer_token ||= refresh_bearer_token
    end

    def request_with_raw_response(uri, method: :get, body: nil, exception_class: RequestError)
      response = http_client.request(http_request_with_bearer_token(uri, method: method, body: body))

      raise exception_class, "#{response.code} #{response.msg}: #{response.body}" unless response.code == '200'

      response.body
    end

    def request_with_json_response(uri, method: :get, body: nil, exception_class: RequestError)
      response = http_client.request(http_request_with_bearer_token(uri, method: method, body: body))

      raise exception_class, "#{response.code} #{response.msg}: #{response.body}" unless response.code == '200'

      JSON.parse(response.body, object_class: OpenStruct)
    end

    def request_with_chunked_response(uri, method: :get, body: nil, exception_class: RequestError)
      raise 'no block provided' unless block_given?

      http_client.request(http_request_with_bearer_token(uri, method: method, body: body)) do |response|
        raise exception_class, "#{response.code} #{response.msg}: #{response.body}" unless response.code == '200'

        chunk_total = 0
        response.read_body do |chunk|
          chunk_total += chunk.size
          yield chunk, chunk_total, response.content_length
        end

        response
      end
    end

    def download_file(uri, method: :get, body: nil, local_file:)
      file = local_file
      file = File.join(@download_path, file) if @download_path

      File.open(file, 'wb') do |f|
        r = request_with_chunked_response(uri, method: method, body: body) do |chunk, _total, _length|
          f.write(chunk)
        end

        DownloadedFile.new(file: file, size: r.content_length)
      end
    end

    def bootstrap_json
      request_with_raw_response(uri(path: 'bootstrap'))
    end

    def bootstrap
      request_with_json_response(uri(path: 'bootstrap'))
    end

    def camera_snapshot(camera:, local_file: nil, time: Time.now)
      ts = time.utc.to_i * 1000
      local_file ||= "#{camera}_#{ts}.jpg"

      query = URI.encode_www_form(force: true, ts: ts)
      download_file(uri(path: "cameras/#{camera}/snapshot", query: query), local_file: local_file)
    end

    def video_export(camera:, start_time:, end_time:, local_file: nil)
      start_ts = start_time.utc.to_i * 1000
      end_ts = end_time.utc.to_i * 1000
      local_file ||= "#{camera}_#{start_ts}_#{end_ts}.mp4"

      query = URI.encode_www_form(camera: camera, start: start_ts, end: end_ts)
      download_file(uri(path: 'video/export', query: query), local_file: local_file)
    end
  end
end
