class LinksStatsController < ApplicationController
  before_action :authenticate_user!
  USER_AGENT_BREAKDOWN_LIMIT = 10

  def index
    links = current_user.links
      .left_joins(:visits)
      .select("links.id, links.long_url, links.slug, links.created_at, COUNT(visits.id) AS total_clicks, COUNT(DISTINCT visits.ip_address) AS unique_visits")
      .group("links.id, links.long_url, links.slug, links.created_at")
      .order(Arel.sql("COUNT(visits.id) DESC, links.created_at DESC"))
      .limit(100)

    visits_by_link_id = build_visits_index(links)

    render json: {
      links: links.map { |link| link_stats_payload(link, visits_by_link_id[link.id] || []) }
    }
  end

  private

  def link_stats_payload(link, user_agents)
    total_clicks = link.read_attribute("total_clicks").to_i
    unique_visits = link.read_attribute("unique_visits").to_i
    logged_visits_count = user_agents.length
    breakdown = build_breakdowns(user_agents, total_clicks)

    {
      id: link.id,
      long_url: link.long_url,
      slug: link.slug,
      created_at: link.created_at,
      total_clicks: total_clicks,
      unique_visits: unique_visits,
      recurrent_visits: total_clicks - unique_visits,
      breakdown_denominator: logged_visits_count,
      device_breakdown: breakdown[:device],
      os_breakdown: breakdown[:os],
      user_agent_breakdown: breakdown[:user_agent]
    }
  end

  def build_visits_index(links)
    link_ids = links.map(&:id)
    return {} if link_ids.empty?

    Visit.where(link_id: link_ids)
      .pluck(:link_id, :user_agent)
      .group_by(&:first)
      .transform_values { |rows| rows.map(&:last) }
  end

  def build_breakdowns(user_agents, _total_clicks)
    logged_visits_count = user_agents.length
    return { device: [], os: [], user_agent: [] } if logged_visits_count.zero?

    device_counts = Hash.new(0)
    os_counts = Hash.new(0)
    user_agent_counts = Hash.new(0)

    user_agents.each do |user_agent|
      normalized_ua = user_agent.to_s.presence || "Unknown"
      user_agent_counts[normalized_ua] += 1

      os_counts[extract_os(normalized_ua)] += 1
      device_counts[extract_device(normalized_ua)] += 1
    end

    {
      device: format_breakdown(device_counts, logged_visits_count),
      os: format_breakdown(os_counts, logged_visits_count),
      user_agent: format_breakdown(
        user_agent_counts,
        logged_visits_count,
        limit: USER_AGENT_BREAKDOWN_LIMIT,
        collapse_other: true
      )
    }
  end

  def format_breakdown(counts, denominator, limit: nil, collapse_other: false)
    sorted = counts
      .sort_by { |name, count| [-count, name] }

    if collapse_other && limit.present? && sorted.length > limit
      top = sorted.first(limit)
      other_count = sorted.drop(limit).sum { |_name, count| count }
      sorted = top + [["Other", other_count]]
    elsif limit.present?
      sorted = sorted.first(limit)
    end

    sorted.map do |name, count|
      {
        name: name,
        count: count,
        percentage: ((count.to_f / denominator) * 100).round(2)
      }
    end
  end

  def extract_os(user_agent)
    parsed = UserAgent.parse(user_agent)
    os = parsed.os.to_s.strip
    return os if os.present?

    extract_os_from_pattern(user_agent)
  rescue StandardError
    extract_os_from_pattern(user_agent)
  end

  def extract_device(user_agent)
    downcased = user_agent.downcase
    return "Tablet" if downcased.match?(/ipad|tablet/)
    return "Mobile" if downcased.match?(/iphone|android|mobile/)
    return "Unknown Device" if downcased == "unknown"

    "Desktop"
  end

  def extract_os_from_pattern(user_agent)
    downcased = user_agent.to_s.downcase
    return "Windows" if downcased.include?("windows")
    return "iOS" if downcased.match?(/iphone|ipad|ios/)
    return "macOS" if downcased.include?("mac os")
    return "Android" if downcased.include?("android")
    return "Linux" if downcased.include?("linux")

    "Unknown OS"
  end
end
