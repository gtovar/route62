require "rails_helper"

RSpec.describe TrackVisitJob, type: :job do
  it "uses safe fallback values when metadata is blank" do
    link = Link.create!(long_url: "https://example.com/content", slug: "abc")

    expect do
      described_class.perform_now(
        link_id: link.id,
        ip_address: "",
        user_agent: nil,
        visited_at: nil
      )
    end.to change(Visit, :count).by(1)

    visit = Visit.last
    expect(visit.ip_address).to eq("0.0.0.0")
    expect(visit.user_agent).to eq("Unknown")
    expect(visit.visited_at).to be_present
  end
end
