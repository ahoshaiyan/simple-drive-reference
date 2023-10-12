# frozen_string_literal: true

module Drive
  class LocalDriver < AbstractDrive
    def initialize(config)
      path = config[:path]

      unless Dir.exist?(path)
        raise ArgumentError, "The path #{path} is not a directory or does not exist."
      end

      @path = Pathname.new(path)
    end

    def name
      'local'
    end

    def store!(id, data)
      unless valid_id?(id)
        raise IdentifierError, 'The ID provided is not acceptable'
      end

      file_name = (@path + id).to_s

      if File.exist?(file_name)
        raise IdentifierExistError, "The identifier #{id} already exists."
      end

      File.open(file_name, 'wb') do |fd|
        fd.write(data)
      end

      nil
    rescue StandardError => e
      raise StoreError, "Could not store data: #{e.message}"
    end

    def retrieve!(id)
      unless valid_id?(id)
        raise IdentifierError, 'The ID provided is not acceptable'
      end

      file_name = (@path + id).to_s

      unless File.exist?(file_name)
        raise NotFoundError, "The data cannot be found: #{id}"
      end

      File.read((@path + id).to_s)
    end

    private

    def valid_id?(id)
      /^[a-z0-9\-_]+$/i.match?(id)
    end
  end
end
