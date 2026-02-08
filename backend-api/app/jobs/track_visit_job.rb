class TrackVisitJob < ApplicationJob
  queue_as :default

  def perform(link_id:, ip_address:, user_agent:, visited_at:)
    Visit.create!(
      link_id: link_id,
      ip_address: ip_address,
      user_agent: user_agent,
      visited_at: visited_at
    )
  end
end
