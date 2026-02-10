require "rails_helper"

RSpec.describe "Links Stats API", type: :request do
  describe "GET /links/stats" do
    it "returns 401 when Authorization header is missing" do
      get "/links/stats"

      expect(response).to have_http_status(:unauthorized)
      body = JSON.parse(response.body)
      expect(body["errors"]).to include("Unauthorized")
    end

    it "returns top links for current user with click metrics" do
      user = User.create!(
        name: "Stats User",
        email: "stats@example.com",
        password: "secret123"
      )
      other_user = User.create!(
        name: "Other User",
        email: "other@example.com",
        password: "secret123"
      )

      link_a = Link.create!(user: user, long_url: "https://example.com/a", slug: "aaa")
      link_b = Link.create!(user: user, long_url: "https://example.com/b", slug: "bbb")
      Link.create!(user: other_user, long_url: "https://example.com/c", slug: "ccc")

      Visit.create!(link: link_a, ip_address: "1.1.1.1", user_agent: "UA", visited_at: Time.current)
      Visit.create!(link: link_a, ip_address: "1.1.1.1", user_agent: "UA", visited_at: Time.current)
      Visit.create!(link: link_a, ip_address: "2.2.2.2", user_agent: "UA", visited_at: Time.current)
      Visit.create!(link: link_b, ip_address: "3.3.3.3", user_agent: "UA", visited_at: Time.current)

      token = AuthTokenService.encode(user_id: user.id)
      get "/links/stats", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].size).to eq(2)

      first = body["links"][0]
      expect(first["id"]).to eq(link_a.id)
      expect(first["total_clicks"]).to eq(3)
      expect(first["unique_visits"]).to eq(2)
      expect(first["recurrent_visits"]).to eq(1)
    end

    it "limits output to 100 links" do
      user = User.create!(
        name: "Limit User",
        email: "limit@example.com",
        password: "secret123"
      )

      101.times do |i|
        Link.create!(
          user: user,
          long_url: "https://example.com/#{i}",
          slug: "s#{i}"
        )
      end

      token = AuthTokenService.encode(user_id: user.id)
      get "/links/stats", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].size).to eq(100)
    end
  end
end
