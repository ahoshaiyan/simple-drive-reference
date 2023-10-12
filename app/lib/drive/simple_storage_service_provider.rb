# frozen_string_literal: true

module Drive
  class SimpleStorageServiceProvider < AbstractDrive
    def initialize(config)
      @base_url = config[:base_url]
      @region = config[:region]
      @bucket = config[:bucket]
      @key_id = config[:key_id]
      @key_secret = config[:key_secret]
    end

    def name
      's3'
    end

    def store!(id, data)
      unless valid_id?(id)
        raise IdentifierError, 'The ID provided is not acceptable'
      end

      url, headers = sign_request(:head, id)
      head_response = MintHttp.header(headers).head(url)
      if head_response.success?
        raise IdentifierExistError, "The identifier #{id} already exists."
      end

      begin
        url, headers = sign_request(:put, id, data)
        MintHttp.header(headers).with_body(data).put(url).raise!
      rescue MintHttp::ClientError => e
        raise StoreError, "Could not store data: #{e.message}"
      rescue StandardError => e
        raise ConnectionError, "The was a problem while storing data: #{e.message}"
      end

      nil
    end

    def retrieve!(id)
      unless valid_id?(id)
        raise IdentifierError, 'The ID provided is not acceptable'
      end

      url, headers = sign_request(:get, id)
      response = MintHttp.header(headers).get(url).raise!
      response.body
    rescue MintHttp::NotFoundError => e
      raise NotFoundError, "The identifier #{id} does not exist"
    rescue StandardError => e
      raise ConnectionError, "The was a problem while retrieving data: #{e.message}"
    end

    private

    # Sign request from the MintHttp::Request instance
    # and update headers to include the signature
    def sign_request(method, path, body = '')
      now = Time.now.utc
      iso_now = now.iso8601.gsub(/[-:]/, '')
      hash_algo = OpenSSL::Digest.new('sha256')
      body_hash = hash_algo.hexdigest(body)

      object_url = (URI.parse(@base_url) + "#{@bucket}/#{path}").to_s

      headers = {
        'Host' => URI.parse(object_url).host,
        'Content-Type' => 'application/octet-stream',
        'x-amz-date' => iso_now,
        'x-amz-content-sha256' => body_hash,
      }

      canonical_headers = headers
        .slice('Host', 'x-amz-date')
        .map { |k, v| "#{k.downcase}:#{v.strip}" }
        .join("\n")

      canonical_request = "#{method.to_s.upcase}\n#{URI.parse(object_url).path}\n\n#{canonical_headers}\n\nhost;x-amz-date\n#{hash_algo.hexdigest(body)}"
      canonical_request = hash_algo.hexdigest(canonical_request)

      string_to_sign = "AWS4-HMAC-SHA256\n#{iso_now}\n#{now.strftime('%Y%m%d')}/#{@region}/s3/aws4_request\n#{canonical_request}"
      signature = OpenSSL::HMAC.hexdigest(hash_algo, signing_key(hash_algo, now), string_to_sign)

      headers['Authorization'] = "AWS4-HMAC-SHA256 Credential=#{@key_id}/#{now.strftime('%Y%m%d')}/#{@region}/s3/aws4_request, SignedHeaders=host;x-amz-date, Signature=#{signature}"

      [object_url, headers]
    end

    def signing_key(hash_algo, time)
      key = OpenSSL::HMAC.digest(hash_algo, "AWS4#{@key_secret}", time.strftime('%Y%m%d'))
      key = OpenSSL::HMAC.digest(hash_algo, key, @region)
      key = OpenSSL::HMAC.digest(hash_algo, key, 's3')
      OpenSSL::HMAC.digest(hash_algo, key, 'aws4_request')
    end

    def valid_id?(id)
      /^[a-z0-9\-_]+$/i.match?(id)
    end
  end
end
