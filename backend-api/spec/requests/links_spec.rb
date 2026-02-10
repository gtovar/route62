require "rails_helper"

RSpec.describe "Links API", type: :request do
  let!(:user) do
    User.create!(
      name: "Link Owner",
      email: "owner@example.com",
      password: "secret123"
    )
  end
  let!(:other_user) do
    User.create!(
      name: "Other Owner",
      email: "other-owner@example.com",
      password: "secret123"
    )
  end
  let(:token) { AuthTokenService.encode(user_id: user.id) }
  let(:auth_headers) { { "Authorization" => "Bearer #{token}" } }
  let(:raw_api_key) { user.rotate_api_key! }
  let(:api_key_headers) { { "Authorization" => "ApiKey #{raw_api_key}" } }
  let(:legacy_api_key_headers) { { "X-API-Key" => raw_api_key } }

  describe "POST /links" do
    it "returns 401 when Authorization header is missing" do
      post "/links", params: { link: { long_url: "https://google.com/very/long/path" } }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end

    it "returns 401 when ApiKey scheme is present without token" do
      post "/links",
           params: { link: { long_url: "https://google.com/very/long/path" } },
           headers: { "Authorization" => "ApiKey" }

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end

    it "returns 401 when Authorization scheme is invalid" do
      post "/links",
           params: { link: { long_url: "https://google.com/very/long/path" } },
           headers: { "Authorization" => "Basic Zm9vOmJhcg==" }

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

    it "accepts Authorization ApiKey auth to create link" do
      post "/links", params: { link: { long_url: "https://example.com/by-api-key" } }, headers: api_key_headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["long_url"]).to eq("https://example.com/by-api-key")
      expect(Link.find(body["id"]).user_id).to eq(user.id)
    end

    it "still accepts legacy X-API-Key auth (deprecated path)" do
      post "/links", params: { link: { long_url: "https://example.com/by-legacy-api-key" } }, headers: legacy_api_key_headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["long_url"]).to eq("https://example.com/by-legacy-api-key")
      expect(Link.find(body["id"]).user_id).to eq(user.id)
    end

    it "gives precedence to Bearer when Bearer and ApiKey are both present" do
      other_token = AuthTokenService.encode(user_id: other_user.id)
      headers = {
        "Authorization" => "Bearer #{other_token}",
        "X-API-Key" => raw_api_key
      }

      post "/links", params: { link: { long_url: "https://example.com/precedence" } }, headers: headers

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(Link.find(body["id"]).user_id).to eq(other_user.id)
    end
  end

  describe "GET /links" do
    it "returns 401 when Authorization header is missing" do
      get "/links"

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end

    it "returns only current user links ordered by creation date desc" do
      old_link = Link.create!(user: user, long_url: "https://example.com/old", slug: "old")
      new_link = Link.create!(user: user, long_url: "https://example.com/new", slug: "new")
      Link.create!(user: other_user, long_url: "https://example.com/other", slug: "other")
      old_link.update_column(:created_at, 2.days.ago)
      new_link.update_column(:created_at, 1.day.ago)

      get "/links", headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].map { |link| link["id"] }).to eq([new_link.id, old_link.id])
      expect(body["pagination"]).to include(
        "page" => 1,
        "per_page" => 10,
        "total_count" => 2,
        "total_pages" => 1
      )
    end

    it "supports pagination params" do
      12.times do |i|
        Link.create!(user: user, long_url: "https://example.com/#{i}", slug: "u#{i}")
      end

      get "/links", params: { page: 2, per_page: 5 }, headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].size).to eq(5)
      expect(body["pagination"]).to include(
        "page" => 2,
        "per_page" => 5,
        "total_count" => 12,
        "total_pages" => 3
      )
    end

    it "accepts Authorization ApiKey auth to list links" do
      Link.create!(user: user, long_url: "https://example.com/api-key-list", slug: "akl")

      get "/links", headers: api_key_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].size).to eq(1)
      expect(body["links"][0]["slug"]).to eq("akl")
    end
  end

  describe "PATCH /links/:id" do
    it "updates current user link" do
      link = Link.create!(user: user, long_url: "https://example.com/old", slug: "abc")

      patch "/links/#{link.id}",
            params: { link: { long_url: "https://example.com/new" } },
            headers: auth_headers

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["long_url"]).to eq("https://example.com/new")
      expect(link.reload.long_url).to eq("https://example.com/new")
    end

    it "returns 404 for link owned by another user" do
      link = Link.create!(user: other_user, long_url: "https://example.com/other", slug: "other")

      patch "/links/#{link.id}",
            params: { link: { long_url: "https://example.com/new" } },
            headers: auth_headers

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Link not found")
    end
  end

  describe "DELETE /links/:id" do
    it "deletes current user link" do
      link = Link.create!(user: user, long_url: "https://example.com/delete", slug: "del")

      expect do
        delete "/links/#{link.id}", headers: auth_headers
      end.to change(Link, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for link owned by another user" do
      link = Link.create!(user: other_user, long_url: "https://example.com/other", slug: "other2")

      delete "/links/#{link.id}", headers: auth_headers

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Link not found")
    end
  end
end
