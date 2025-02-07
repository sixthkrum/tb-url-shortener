# frozen_string_literal: true

class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 3, within: 1.hours, only: :create, with: -> { redirect_to new_user_url, alert: "Try again later." }

  # creating users without validating ownership of email for now as that is outside the scope
  def create
    return redirect_to root_url if authenticated?

    user = User.new(user_params)

    if user.save
      respond_to do |format|
        format.html do
          return redirect_to new_session_path, notice: "Signed up successfully, please sign in"
        end

        format.json do
          return render json: { data: { message: "Signed up successfully" }, errors: [] }, status: :no_content
        end
      end
    end

    error_message = "Failed to sign up, #{user.errors.full_messages.to_sentence}"
    respond_to do |format|
      format.html do
        return redirect_to new_user_path, alert: error_message
      end

      format.json do
        return render json: { data: {}, errors: [ { message: error_message } ] }, status: :no_content
      end
    end
  end

  def new
    redirect_to root_url if authenticated?
  end

  private

  def user_params
    params.expect(user: [ :email_address, :password ])
  end
end
