class LinksTopController < ApplicationController
  TOP_LINKS_CACHE_KEY = "links_top:v1"
  TOP_LINKS_TTL = 60.seconds

  def index
    payload = Rails.cache.fetch(TOP_LINKS_CACHE_KEY, expires_in: TOP_LINKS_TTL) do
      links = Link.left_joins(:visits)
        .select("links.id, links.long_url, links.slug, links.created_at, COUNT(visits.id) AS total_clicks, COUNT(DISTINCT visits.ip_address) AS unique_visits")
        .group("links.id, links.long_url, links.slug, links.created_at")
        .order(Arel.sql("COUNT(visits.id) DESC, links.created_at DESC"))
        .limit(100)

      {
        links: links.map { |link| top_link_payload(link) }
      }
    end

    render json: payload
  end

  private

  def top_link_payload(link)
    {
      id: link.id,
      slug: link.slug,
      long_url: link.long_url,
      created_at: link.created_at,
      total_clicks: link.read_attribute("total_clicks").to_i,
      unique_visits: link.read_attribute("unique_visits").to_i
    }
  end
end
