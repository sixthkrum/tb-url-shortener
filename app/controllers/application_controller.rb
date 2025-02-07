class ApplicationController < ActionController::Base
  protect_from_forgery unless: Proc.new { |c| c.request.format.match?(:json) }

  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActionController::ParameterMissing do |_|
    error_message = "Invalid parameters passed"
    respond_to do |format|
      format.json do
        render json: { data: {}, errors: [ { message: error_message } ] }, status: :bad_request
      end

      format.html do
        render plain: error_message, status: :bad_request
      end
    end
  end
end
