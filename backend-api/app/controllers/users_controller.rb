class UsersController < ApplicationController
  def create
    user = User.new(user_params)

    if user.save
      token = AuthTokenService.encode(user_id: user.id)
      render json: { user: user_payload(user), token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end

  def user_payload(user)
    {
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
