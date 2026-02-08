class RedirectsController < ApplicationController
  def show
    link = Link.find_by(slug: params[:slug])

    if link
      TrackVisitJob.perform_later(
        link_id: link.id,
        ip_address: request.remote_ip,
        user_agent: request.user_agent.to_s,
        visited_at: Time.current
      )
      redirect_to link.long_url, status: :moved_permanently, allow_other_host: true
    else
      render json: { error: "Short link not found" }, status: :not_found
    end
  end
end
