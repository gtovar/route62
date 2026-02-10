class ApplicationController < ActionController::API
  private

  def authenticate_user!
    return if current_user.present?

    render json: { errors: ["Unauthorized"] }, status: :unauthorized
  end

  def current_user
    return @current_user if defined?(@current_user)

    token = bearer_token
    return @current_user = nil if token.blank?

    payload = AuthTokenService.decode(token)
    user_id = payload["user_id"] || payload[:user_id]
    @current_user = User.find_by(id: user_id)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    @current_user = nil
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    scheme, token = header.split(" ", 2)
    return token if scheme == "Bearer"

    nil
  end
end
