class ApiKeysController < ApplicationController
  before_action :authenticate_user_with_jwt!

  def rotate
    new_api_key = current_user.rotate_api_key!

    render json: {
      api_key: new_api_key,
      api_key_last4: current_user.api_key_last4
    }, status: :ok
  end
end
