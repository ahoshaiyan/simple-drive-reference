# frozen_string_literal: true

module Drive
  class DatabaseDriver < AbstractDrive
    def name
      'db'
    end

    def store!(id, data)
      if DbBlob.where(identifier: id).exists?
        raise IdentifierExistError, "The identifier #{id} already exists"
      end

      DbBlob.create!(identifier: id, data: data)
      nil
    rescue StandardError => e
      raise StoreError, "Could not store data: #{e.message}"
    end

    def retrieve!(id)
      db_blob = DbBlob.where(identifier: id).first

      unless db_blob
        raise NotFoundError, "The identifier #{id} does not exist"
      end

      db_blob.data
    end
  end
end
