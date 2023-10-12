# frozen_string_literal: true

module HandlesFrameworkErrors
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from BusinessError, with: :handle_business_error
  end

  def handle_record_not_found(error)
    render json: { message: "The #{error.model} you were looking for was not found." }, status: :not_found
  end

  def handle_business_error(error)
    render json: { message: error.message }, status: :bad_request
  end
end
