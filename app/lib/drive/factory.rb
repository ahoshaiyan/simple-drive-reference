# frozen_string_literal: true

module Drive
  class Factory
    def self.make_drive(provider = nil)
      case provider || default_provider
        when 'db'
          DatabaseDriver.new
        when 'local'
          LocalDriver.new(local_config)
        when 's3'
          SimpleStorageServiceProvider.new(s3_config)
        else
          raise ArgumentError, "Invalid storage provider: #{provider || 'no set'}"
      end
    end

    private

    def self.config
      @config ||= Rails.configuration.drive
    end

    def self.default_provider
      config[:provider]
    end

    def self.local_config
      config[:local]
    end

    def self.s3_config
      config[:s3]
    end
  end
end
