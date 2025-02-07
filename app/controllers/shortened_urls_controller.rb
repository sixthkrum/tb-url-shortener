# frozen_string_literal: true

class ShortenedUrlsController < ApplicationController
  include Authentication

  allow_unauthenticated_access only: %i[ show create new ]
  def show
    shortened_url = ShortenedUrl.find_by_id(Base64.urlsafe_decode64(params[:id]))

    redirect_to shortened_url&.original_url || root_url, allow_other_host: true
  end

  def create
    # shortened_url = Current.session.user.shortened_urls.new(shortened_url_params)
    shortened_url = ShortenedUrl.new(shortened_url_params)

    if shortened_url.save
      return redirect_to new_shortened_url_path,
                         notice: "URL shortened: #{shortened_url_url(Base64.urlsafe_encode64(shortened_url.id.to_s))}"
    end

    redirect_to new_shortened_url_path,
                alert: "Failed to create shortened URL, #{shortened_url.errors.full_messages.to_sentence}"
  end

  def new; end

  def destroy; end

  def index; end

  private

  def shortened_url_params
    params.expect(shortened_url: [ :original_url ])
  end
end
