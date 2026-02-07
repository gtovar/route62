class LinksController < ApplicationController
  def create
    link = Link.new(link_params)

    if link.save
      begin
        link.assign_unique_slug!
        render json: link_payload(link), status: :created
      rescue ActiveRecord::RecordInvalid
        render json: { errors: ["Slug has already been taken"] }, status: :unprocessable_content
      rescue ActiveRecord::RecordNotUnique
        render json: { errors: ["Slug has already been taken"] }, status: :unprocessable_content
      end
    else
      render json: { errors: link.errors.full_messages }, status: :unprocessable_content
    end
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
