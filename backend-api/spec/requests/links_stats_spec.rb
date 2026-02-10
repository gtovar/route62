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
      expect(first["breakdown_denominator"]).to eq(3)
      expect(first["device_breakdown"]).to eq([{ "name" => "Desktop", "count" => 3, "percentage" => 100.0 }])
      expect(first["os_breakdown"]).to eq([{ "name" => "Unknown OS", "count" => 3, "percentage" => 100.0 }])
      expect(first["user_agent_breakdown"]).to eq([{ "name" => "UA", "count" => 3, "percentage" => 100.0 }])
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

    it "accepts Authorization ApiKey auth" do
      user = User.create!(
        name: "Api Key User",
        email: "apikey@example.com",
        password: "secret123"
      )
      raw_api_key = user.rotate_api_key!
      link = Link.create!(user: user, long_url: "https://example.com/key", slug: "key")
      Visit.create!(link: link, ip_address: "4.4.4.4", user_agent: "UA", visited_at: Time.current)

      get "/links/stats", headers: { "Authorization" => "ApiKey #{raw_api_key}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].size).to eq(1)
      expect(body["links"][0]["slug"]).to eq("key")
    end

    it "returns device/os/user-agent percentage breakdowns" do
      user = User.create!(
        name: "Breakdown User",
        email: "breakdown@example.com",
        password: "secret123"
      )

      link = Link.create!(user: user, long_url: "https://example.com/device", slug: "dev1")
      Visit.create!(
        link: link,
        ip_address: "1.1.1.1",
        user_agent: "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)",
        visited_at: Time.current
      )
      Visit.create!(
        link: link,
        ip_address: "2.2.2.2",
        user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        visited_at: Time.current
      )
      Visit.create!(
        link: link,
        ip_address: "3.3.3.3",
        user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
        visited_at: Time.current
      )

      token = AuthTokenService.encode(user_id: user.id)
      get "/links/stats", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      stats = body["links"][0]
      expect(stats["breakdown_denominator"]).to eq(3)

      expect(stats["device_breakdown"]).to eq(
        [
          { "name" => "Desktop", "count" => 2, "percentage" => 66.67 },
          { "name" => "Mobile", "count" => 1, "percentage" => 33.33 }
        ]
      )
      expect(stats["os_breakdown"]).to include(
        { "name" => "Windows", "count" => 2, "percentage" => 66.67 }
      )
      expect(stats["user_agent_breakdown"]).to eq(
        [
          { "name" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64)", "count" => 2, "percentage" => 66.67 },
          { "name" => "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", "count" => 1, "percentage" => 33.33 }
        ]
      )
    end

    it "classifies iPad as Tablet and collapses long user-agent tail into Other" do
      user = User.create!(
        name: "Tablet User",
        email: "tablet@example.com",
        password: "secret123"
      )

      link = Link.create!(user: user, long_url: "https://example.com/tablet", slug: "tb1")

      Visit.create!(
        link: link,
        ip_address: "10.0.0.1",
        user_agent: "Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X) Mobile/15E148",
        visited_at: Time.current
      )

      11.times do |index|
        Visit.create!(
          link: link,
          ip_address: "10.0.1.#{index}",
          user_agent: "UniqueAgent/#{index}",
          visited_at: Time.current
        )
      end

      token = AuthTokenService.encode(user_id: user.id)
      get "/links/stats", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      stats = body["links"][0]
      expect(stats["breakdown_denominator"]).to eq(12)

      expect(stats["device_breakdown"]).to include(
        { "name" => "Tablet", "count" => 1, "percentage" => 8.33 }
      )
      expect(stats["user_agent_breakdown"].size).to eq(11)
      expect(stats["user_agent_breakdown"]).to include(
        { "name" => "Other", "count" => 2, "percentage" => 16.67 }
      )
    end
  end
end
