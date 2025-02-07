# frozen_string_literal: true

class User < ApplicationRecord
  JWT_AUD = "user"

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :shortened_urls, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def generate_jwt_hmac512(expires_in: (Time.now + 1.hours).to_i)
    JWT.encode({ exp: expires_in, sub: id, aud: JWT_AUD },
               Rails.application.credentials.jwt_secrets[:HS512],
               "HS512")
  end

  # authenticate by jwt token, allow for more than 1 kind of token to exist in the application
  def self.authenticate_by_jwt(token)
    unverified_token = JWT::EncodedToken.new(token)

    decode_options = { aud: JWT_AUD, verify_aud: true }

    case unverified_token.header["alg"]
    when "HS512"
      key = Rails.application.credentials.jwt_secrets[:HS512]
      decode_options[:algorithm] = "HS512"
    else
      return nil
    end

    begin
      decoded_token = JWT.decode(token, key, true, decode_options)

      User.find_by(id: decoded_token[0]["sub"])
    rescue JWT::ExpiredSignature
      nil
    end
  end
end
