class LinksStatsController < ApplicationController
  before_action :authenticate_user!

  def index
    links = current_user.links
      .left_joins(:visits)
      .select("links.id, links.long_url, links.slug, links.created_at, COUNT(visits.id) AS total_clicks, COUNT(DISTINCT visits.ip_address) AS unique_visits")
      .group("links.id")
      .order(Arel.sql("COUNT(visits.id) DESC, links.created_at DESC"))
      .limit(100)

    render json: {
      links: links.map { |link| link_stats_payload(link) }
    }
  end

  private

  def link_stats_payload(link)
    total_clicks = link.read_attribute("total_clicks").to_i
    unique_visits = link.read_attribute("unique_visits").to_i

    {
      id: link.id,
      long_url: link.long_url,
      slug: link.slug,
      created_at: link.created_at,
      total_clicks: total_clicks,
      unique_visits: unique_visits,
      recurrent_visits: total_clicks - unique_visits
    }
  end
end
