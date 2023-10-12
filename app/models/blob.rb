# frozen_string_literal: true

class Blob < ApplicationRecord
  def self.store!(id, data)
    begin
      data = Base64.strict_decode64(data)
    rescue ArgumentError => e
      raise BusinessError, "Data must be a valid Base64 string"
    end

    drive = Drive::Factory.make_drive
    drive.store!(id, data)

    Blob.create!(provider: drive.name, blob_id: id, size: data.length)
  end

  def data
    @data ||= retrieve_data
  end

  private

  def retrieve_data
    Base64.strict_encode64(drive_service.retrieve!(blob_id))
  end

  def drive_service
    Drive::Factory.make_drive(provider)
  end
end
