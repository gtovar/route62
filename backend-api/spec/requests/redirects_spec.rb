require "rails_helper"

RSpec.describe "Redirects API", type: :request do
  include ActiveJob::TestHelper

  around do |example|
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
    clear_performed_jobs
    example.run
    clear_enqueued_jobs
    clear_performed_jobs
    ActiveJob::Base.queue_adapter = previous_adapter
  end

  describe "GET /:slug" do
    it "redirects with 301 when slug exists" do
      Link.create!(long_url: "https://example.com/content", slug: "abc")

      get "/abc"

      expect(response).to have_http_status(:moved_permanently)
      expect(response.headers["Location"]).to eq("https://example.com/content")
    end

    it "enqueues visit tracking asynchronously when slug exists" do
      Link.create!(long_url: "https://example.com/content", slug: "abc")

      expect do
        get "/abc", headers: { "User-Agent" => "RSpec Browser" }
      end.to have_enqueued_job(TrackVisitJob).with(
        hash_including(
          link_id: Link.find_by!(slug: "abc").id,
          ip_address: "127.0.0.1",
          user_agent: "RSpec Browser"
        )
      )
    end

    it "uses a safe fallback when User-Agent is missing" do
      Link.create!(long_url: "https://example.com/content", slug: "abc")

      expect do
        get "/abc", headers: { "User-Agent" => "" }
      end.to have_enqueued_job(TrackVisitJob).with(
        hash_including(
          link_id: Link.find_by!(slug: "abc").id,
          ip_address: "127.0.0.1",
          user_agent: "Unknown"
        )
      )
    end

    it "returns 404 when slug does not exist" do
      get "/missing"

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]).to eq("Short link not found")
    end
  end
end
