class LinksTopController < ApplicationController
  def index
    links = Link.left_joins(:visits)
      .select("links.id, links.long_url, links.slug, links.created_at, COUNT(visits.id) AS total_clicks, COUNT(DISTINCT visits.ip_address) AS unique_visits")
      .group("links.id, links.long_url, links.slug, links.created_at")
      .order(Arel.sql("COUNT(visits.id) DESC, links.created_at DESC"))
      .limit(100)

    render json: {
      links: links.map { |link| top_link_payload(link) }
    }
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
