class RedirectsController < ApplicationController
  def show
    link = Link.find_by(slug: params[:slug])

    if link
      redirect_to link.long_url, status: :moved_permanently, allow_other_host: true
    else
      render json: { error: "Short link not found" }, status: :not_found
    end
  end
end
