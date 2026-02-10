require "rails_helper"

RSpec.describe "Users API", type: :request do
  describe "POST /signup" do
    it "creates the user and returns a token when data is valid" do
      post "/signup", params: {
        user: {
          name: "Jane Doe",
          email: "jane@example.com",
          password: "secret123"
        }
      }

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["user"]["name"]).to eq("Jane Doe")
      expect(body["user"]["email"]).to eq("jane@example.com")
      expect(body["user"]["api_key"]).to be_present
      expect(body["user"]["api_key_last4"]).to eq(body["user"]["api_key"][-4..])
      expect(body["token"]).to be_present

      decoded = AuthTokenService.decode(body["token"])
      expect(decoded["user_id"]).to eq(body["user"]["id"])
    end

    it "blocks sign-up when email is already taken" do
      User.create!(
        name: "First User",
        email: "jane@example.com",
        password: "secret123"
      )

      post "/signup", params: {
        user: {
          name: "Second User",
          email: "jane@example.com",
          password: "secret999"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Email has already been taken")
    end

    it "returns 422 when the database raises RecordNotUnique" do
      allow_any_instance_of(User).to receive(:save).and_raise(ActiveRecord::RecordNotUnique)

      post "/signup", params: {
        user: {
          name: "Race Condition User",
          email: "race@example.com",
          password: "secret123"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Email has already been taken")
    end
  end

  describe "POST /login" do
    let!(:user) do
      User.create!(
        name: "Login User",
        email: "login@example.com",
        password: "secret123"
      )
    end

    it "returns token and user payload when credentials are valid" do
      post "/login", params: {
        user: {
          email: "login@example.com",
          password: "secret123"
        }
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body["user"]["id"]).to eq(user.id)
      expect(body["user"]["email"]).to eq("login@example.com")
      expect(body["user"]["api_key"]).to be_nil
      expect(body["user"]["api_key_last4"]).to eq(user.api_key_last4)
      expect(body["token"]).to be_present

      decoded = AuthTokenService.decode(body["token"])
      expect(decoded["user_id"]).to eq(user.id)
    end

    it "returns 401 when email is invalid" do
      post "/login", params: {
        user: {
          email: "missing@example.com",
          password: "secret123"
        }
      }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Invalid email or password")
    end

    it "returns 401 when password is invalid" do
      post "/login", params: {
        user: {
          email: "login@example.com",
          password: "wrong-password"
        }
      }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Invalid email or password")
    end
  end
end
