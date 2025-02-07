class ApplicationController < ActionController::Base
  protect_from_forgery unless: Proc.new { |c| c.request.format.match?(:json) }

  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
