require "rails_helper"

RSpec.describe "Links Top API", type: :request do
  describe "GET /links/top" do
    it "returns top links globally without authentication" do
      user = User.create!(name: "Top User", email: "top-user@example.com", password: "secret123")
      link_a = Link.create!(user: user, long_url: "https://example.com/a", slug: "topa")
      link_b = Link.create!(user: user, long_url: "https://example.com/b", slug: "topb")

      25.times do |i|
        Visit.create!(link: link_a, ip_address: "1.1.1.#{i}", user_agent: "UA", visited_at: Time.current)
      end
      10.times do |i|
        Visit.create!(link: link_b, ip_address: "2.2.2.#{i}", user_agent: "UA", visited_at: Time.current)
      end

      get "/links/top"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].length).to be <= 100

      row_a = body["links"].find { |row| row["slug"] == "topa" }
      row_b = body["links"].find { |row| row["slug"] == "topb" }
      expect(row_a).to include(
        "total_clicks" => 25,
        "unique_visits" => 25
      )
      expect(row_b).to include(
        "total_clicks" => 10,
        "unique_visits" => 10
      )

      slugs = body["links"].map { |row| row["slug"] }
      expect(slugs.index("topa")).to be < slugs.index("topb")
    end

    it "limits response to 100 links" do
      user = User.create!(name: "Top Limit User", email: "top-limit@example.com", password: "secret123")

      101.times do |i|
        link = Link.create!(user: user, long_url: "https://example.com/top-#{i}", slug: "gt#{i}")
        Visit.create!(link: link, ip_address: "3.3.3.#{i}", user_agent: "UA", visited_at: Time.current)
      end

      get "/links/top"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["links"].length).to eq(100)
    end

    it "breaks ties by created_at desc when click counts are equal" do
      user = User.create!(name: "Top Tie User", email: "top-tie@example.com", password: "secret123")
      older = Link.create!(user: user, long_url: "https://example.com/old", slug: "oldtie")
      newer = Link.create!(user: user, long_url: "https://example.com/new", slug: "newtie")

      older.update_column(:created_at, 2.days.ago)
      newer.update_column(:created_at, 1.day.ago)

      2.times do |i|
        Visit.create!(link: older, ip_address: "4.4.4.#{i}", user_agent: "UA", visited_at: Time.current)
        Visit.create!(link: newer, ip_address: "5.5.5.#{i}", user_agent: "UA", visited_at: Time.current)
      end

      get "/links/top"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      slugs = body["links"].map { |row| row["slug"] }

      expect(slugs.index("newtie")).to be < slugs.index("oldtie")
    end
  end
end
