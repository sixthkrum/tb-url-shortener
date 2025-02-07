module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    check_authentication
  end

  def require_authentication
    check_authentication || request_authentication
  end

  def check_authentication
    resume_session || authenticate_with_token
  end

  def authenticate_with_token
    header = request.headers["Authorization"]

    return nil unless header

    # can extend this to support other kinds of token as required
    # only allow tokens sent in the format of Bearer #{token}
    token_type, token_value = header.split(" ")

    # assumes all bearer tokens to be JWTs, this can be extended in case different types of bearer tokens are required
    # through inspecting the type of token server side
    case token_type
    when "Bearer"
      Current.user = User.authenticate_by_jwt(token_value)
    else
      nil
    end
  end

  def resume_session
    Current.session ||= find_session_by_cookie
    Current.user ||= Current.session.user unless Current.session.nil?
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
