class LinksController < ApplicationController
  before_action :authenticate_user!

  def create
    link = current_user.links.new(link_params)

    Link.transaction do
      link.save!
      link.assign_unique_slug!
    end

    render json: link_payload(link), status: :created
  rescue ActiveRecord::RecordInvalid => error
    render json: { errors: error.record.errors.full_messages }, status: :unprocessable_content
  rescue ActiveRecord::RecordNotUnique
    render json: { errors: ["Slug has already been taken"] }, status: :unprocessable_content
  end

  private

  def link_params
    params.require(:link).permit(:long_url)
  end

  def link_payload(link)
    {
      id: link.id,
      long_url: link.long_url,
      slug: link.slug,
      short_url: "#{request.base_url}/#{link.slug}"
    }
  end
end
