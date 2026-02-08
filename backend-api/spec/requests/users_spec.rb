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
end
