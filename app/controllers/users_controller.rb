# frozen_string_literal: true

class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  # creating users without validating ownership of email for now as that is outside the scope
  def create
    user = User.new(user_params)

    return redirect_to new_session_path, notice: "Signed up successfully, please sign in" if user.save

    redirect_to new_user_path,
                alert: "Failed to sign up, #{user.errors.full_messages.to_sentence}"
  end

  def new; end

  private

  def user_params
    params.expect(user: [ :email_address, :password ])
  end
end
