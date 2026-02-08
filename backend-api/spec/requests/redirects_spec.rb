require "rails_helper"

RSpec.describe "Redirects API", type: :request do
  describe "GET /:slug" do
    it "redirects with 301 when slug exists" do
      Link.create!(long_url: "https://example.com/content", slug: "abc")

      get "/abc"

      expect(response).to have_http_status(:moved_permanently)
      expect(response.headers["Location"]).to eq("https://example.com/content")
    end

    it "returns 404 when slug does not exist" do
      get "/missing"

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Short link not found")
    end
  end
end
