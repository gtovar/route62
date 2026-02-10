require "rails_helper"

RSpec.describe "API Keys API", type: :request do
  describe "POST /api_keys/rotate" do
    let!(:user) do
      User.create!(
        name: "Rotate User",
        email: "rotate@example.com",
        password: "secret123"
      )
    end
    let(:token) { AuthTokenService.encode(user_id: user.id) }

    it "rotates api key when Bearer token is valid" do
      old_digest = user.api_key_digest

      post "/api_keys/rotate", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["api_key"]).to be_present
      expect(body["api_key_last4"]).to eq(body["api_key"][-4..])
      expect(user.reload.api_key_digest).not_to eq(old_digest)
      expect(user.api_key_last4).to eq(body["api_key_last4"])
    end

    it "returns 401 when Bearer token is missing" do
      post "/api_keys/rotate"

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end

    it "returns 401 when only ApiKey auth is provided" do
      raw_api_key = user.rotate_api_key!
      post "/api_keys/rotate", headers: { "Authorization" => "ApiKey #{raw_api_key}" }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end
  end
end
