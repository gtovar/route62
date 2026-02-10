class ApplicationController < ActionController::API
  private

  def authenticate_user!
    return if current_user.present?

    render json: { errors: ["Unauthorized"] }, status: :unauthorized
  end

  def current_user
    return @current_user if defined?(@current_user)

    jwt_user = user_from_bearer_token
    return @current_user = jwt_user if jwt_user.present?

    api_key_user = user_from_api_key
    return @current_user = api_key_user if api_key_user.present?

    legacy_api_key_user = user_from_legacy_api_key
    return @current_user = legacy_api_key_user if legacy_api_key_user.present?

    @current_user = nil
  end

  def authenticate_user_with_jwt!
    user = user_from_bearer_token
    return @current_user = user if user.present?

    render json: { errors: ["Unauthorized"] }, status: :unauthorized
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    scheme, token = header.split(" ", 2)
    return token if scheme == "Bearer"

    nil
  end

  def api_key_from_authorization_header
    header = request.headers["Authorization"].to_s
    scheme, token = header.split(" ", 2)
    return token.to_s if scheme&.casecmp("ApiKey")&.zero?

    ""
  end

  def user_from_bearer_token
    token = bearer_token
    return nil if token.blank?

    payload = AuthTokenService.decode(token)
    user_id = payload["user_id"] || payload[:user_id]
    User.find_by(id: user_id)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def user_from_api_key
    api_key = api_key_from_authorization_header
    return nil if api_key.blank?

    User.find_by_api_key(api_key)
  end

  def user_from_legacy_api_key
    api_key = request.headers["X-API-Key"].to_s
    return nil if api_key.blank?

    User.find_by_api_key(api_key)
  end
end
