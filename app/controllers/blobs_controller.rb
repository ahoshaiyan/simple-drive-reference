# frozen_string_literal: true

class BlobsController < ApplicationController
  before_action :authenticate_request

  def create
    params = blob_params
    Blob.store!(params[:id], params[:data])
    render status: :created
  rescue Drive::DriveError => e
    render json: { message: e.message }, status: :bad_gateway
  end

  def show
    render json: {
      id: blob.id,
      data: blob.data,
      size: blob.size,
      created_at: blob.created_at.iso8601,
    }
  end

  private

  def blob
    @blob ||= Blob.where(blob_id: params[:id]).first!
  end

  # Validate create blob request params
  # there are much better ways to validate data here
  # but we are keeping it simple
  def blob_params
    if params[:id].blank?
      raise BusinessError, "The field (id) is required"
    end

    if params[:data].blank?
      raise BusinessError, "The field (data) is required"
    end

    params.permit(:id, :data)
  end
end
