# frozen_string_literal: true

module Drive
  class AbstractDrive
    def name
      raise NotImplementedError
    end

    def store!(id, data)
      raise NotImplementedError
    end

    def retrieve!(id)
      raise NotImplementedError
    end
  end
end
