class SessionsController < ApplicationController
  def create
    user = User.find_by(email: login_email)

    unless user&.authenticate(login_password)
      return render json: { errors: ["Invalid email or password"] }, status: :unauthorized
    end

    token = AuthTokenService.encode(user_id: user.id)
    render json: { user: user_payload(user), token: token }, status: :ok
  end

  private

  def login_params
    params.require(:user).permit(:email, :password)
  end

  def login_email
    login_params[:email].to_s.strip.downcase
  end

  def login_password
    login_params[:password].to_s
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      api_key_last4: user.api_key_last4
    }
  end
end
