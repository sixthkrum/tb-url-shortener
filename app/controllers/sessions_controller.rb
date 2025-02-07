# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
    respond_to do |format|
      format.html do
        redirect_to root_url if authenticated?
      end

      format.json do
        return render json: { data: {}, errors: [] }, status: :no_content
      end
    end
  end

  def create
    redirect_to root_url if authenticated? && request.format.html?

    user = User.authenticate_by(params.permit(:email_address, :password))

    if user
      respond_to do |format|
        format.html do
          start_new_session_for user

          return redirect_to after_authentication_url
        end
        format.json do
          return render json: { data: { token: user.generate_jwt_hmac512 }, errors: [] }, status: :ok
        end
      end
    end

    error_message = "Try another email address or password."
    respond_to do |format|
      format.html do
        return redirect_to new_session_path, alert: error_message
      end
      format.json do
        return render json: { data: {}, errors: [ { message: error_message } ] }, status: :bad_request
      end
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
