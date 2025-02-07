# frozen_string_literal: true

class ShortenedUrlsController < ApplicationController
  include Authentication

  rate_limit to: 30, within: 30.minutes, only: :create, with: -> { redirect_to new_shortened_url_url, alert: "Try again later." }
  allow_unauthenticated_access only: %i[ show ]

  def show
    # use base64 to create a short slug for the url
    # this is enumerable so sensitive URLs should never be shortened using this
    shortened_url = ShortenedUrl.find_by_id(Base64.urlsafe_decode64(params[:id]))

    # redirect to the home page of the service if no match is found
    redirect_to shortened_url&.original_url || root_url, allow_other_host: true
  end

  def create
    shortened_url = Current.user.shortened_urls.new(shortened_url_params)

    if shortened_url.save
      url = shortened_url_url(shortened_url.short_slug)

      respond_to do |format|
        format.html do
          return redirect_to new_shortened_url_path, notice: "URL shortened: #{url}"
        end

        format.json do
          return render json: { data: { shortened_url: { shortened_url: url, id: shortened_url.id } }, errors: [] }, status: :created
        end
      end
    end

    error_message = shortened_url.errors.full_messages.to_sentence
    respond_to do |format|
      format.html do
        return redirect_to new_shortened_url_path, alert: "Failed to create shortened URL, #{error_message}"
      end

      format.json do
        return render json: { data: {}, errors: [ { message: error_message } ] }, status: :bad_request
      end
    end
  end

  def new; end

  def destroy
    deletion_count = Current.user.shortened_urls.delete_by(id: params[:id])

    respond_to do |format|
      format.html do
        return redirect_back fallback_location: root_url
      end

      format.json do
        return render json: { data: { deletion_count: deletion_count }, errors: [] }, status: :ok
      end
    end
  end

  def index
    @shortened_urls = Current.user.shortened_urls.map do |s|
      {
        id: s.id,
        shortened_url: shortened_url_url(s.short_slug),
        original_url: s.original_url,
        created_at: s.created_at
      }
    end

    respond_to do |format|
      format.html do; end

      format.json do
        return render json: { data: { shortened_urls: @shortened_urls }, errors: [] }, status: :ok
      end
    end
  end

  private

  def shortened_url_params
    params.expect(shortened_url: [ :original_url ])
  end
end
