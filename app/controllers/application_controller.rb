# frozen_string_literal: true

class ApplicationController < ActionController::API
  include HandlesFrameworkErrors

  protected

  def authenticate_request
    token = bearer_token
    api_key = Rails.configuration.drive[:api_key]

    if api_key.blank?
      raise ArgumentError, 'API is not set, please set the API key and re-run the server again.'
    end

    authenticated = token && ActiveSupport::SecurityUtils.secure_compare(token, api_key)

    unless authenticated
      render json: { message: 'Unauthenticated' }, status: :unauthorized
    end
  end

  def bearer_token
    token = request.authorization

    unless token&.start_with?('Bearer ')
      return nil
    end

    token.delete_prefix('Bearer ')
  end
end
