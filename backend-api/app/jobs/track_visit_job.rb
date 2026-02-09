class TrackVisitJob < ApplicationJob
  queue_as :default

  def perform(link_id:, ip_address:, user_agent:, visited_at:)
    Visit.create!(
      link_id: link_id,
      ip_address: ip_address.presence || "0.0.0.0",
      user_agent: user_agent.presence || "Unknown",
      visited_at: visited_at || Time.current
    )
  end
end
