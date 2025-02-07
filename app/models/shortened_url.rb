class ShortenedUrl < ApplicationRecord
  include UrlValidation
  belongs_to :user

  validates :original_url, presence: true
  validate :original_url_is_a_valid_http_url

  def original_url_is_a_valid_http_url
    unless ShortenedUrl.valid_http_url?(original_url)
      errors.add(:original_url, "is not a valid HTTP URL")
    end
  end

  def short_slug
    Base64.urlsafe_encode64(id.to_s)
  end
end
