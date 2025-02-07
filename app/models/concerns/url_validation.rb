module UrlValidation
  extend ActiveSupport::Concern

  module ClassMethods
    def valid_http_url?(url)
      parsed_uri = URI.parse(url)
      parsed_uri.host.present?
    rescue URI::InvalidURIError
      false
    end
  end
end
