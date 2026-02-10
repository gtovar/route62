require "rails_helper"

RSpec.describe "Links API", type: :request do
  describe "POST /links" do
    let!(:user) do
      User.create!(
        name: "Link Owner",
        email: "owner@example.com",
        password: "secret123"
      )
    end
    let(:token) { AuthTokenService.encode(user_id: user.id) }
    let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }

    it "returns 401 when Authorization header is missing" do
      post "/links", params: { link: { long_url: "https://google.com/very/long/path" } }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end

    it "creates a short link for a valid URL" do
      post "/links", params: { link: { long_url: "https://google.com/very/long/path" } }, headers: auth_headers

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body["long_url"]).to eq("https://google.com/very/long/path")
      expect(body["slug"]).to be_present
      expect(body["short_url"]).to eq("http://www.example.com/#{body["slug"]}")
      expect(Link.find(body["id"]).user_id).to eq(user.id)
    end

    it "returns Invalid URL format for invalid URL input" do
      post "/links", params: { link: { long_url: "not-a-url" } }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Long url Invalid URL format")
    end

    it "returns an error when a slug collision happens" do
      Link.create!(long_url: "https://existing.example.com", slug: "7")

      allow(ShortenerService).to receive(:encode).and_return("7")

      post "/links", params: { link: { long_url: "https://new.example.com" } }, headers: auth_headers

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Slug has already been taken")
    end
  end
end
