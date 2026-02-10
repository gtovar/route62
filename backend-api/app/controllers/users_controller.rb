class UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      token = AuthTokenService.encode(user_id: user.id)
      render json: { user: signup_user_payload(user), token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: ["Email has already been taken"] }, status: :unprocessable_content
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def signup_user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      api_key: user.plain_api_key,
      api_key_last4: user.api_key_last4
    }
  end
end
