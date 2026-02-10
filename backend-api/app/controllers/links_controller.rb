class LinksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_link, only: [:update, :destroy]

  DEFAULT_PAGE = 1
  DEFAULT_PER_PAGE = 10
  MAX_PER_PAGE = 100

  def index
    page = normalized_page
    per_page = normalized_per_page

    links_scope = current_user.links.order(created_at: :desc)
    total_count = links_scope.count
    total_pages = (total_count.to_f / per_page).ceil
    total_pages = 1 if total_pages.zero?

    links = links_scope.offset((page - 1) * per_page).limit(per_page)

    render json: {
      links: links.map { |link| link_payload(link) },
      pagination: {
        page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: total_pages
      }
    }, status: :ok
  end

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

  def update
    if @link.update(link_params)
      render json: link_payload(@link), status: :ok
    else
      render json: { errors: @link.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @link.destroy!
    head :no_content
  end

  private

  def set_link
    @link = current_user.links.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ["Link not found"] }, status: :not_found
  end

  def normalized_page
    page = params[:page].to_i
    page > 0 ? page : DEFAULT_PAGE
  end

  def normalized_per_page
    per_page = params[:per_page].to_i
    per_page = DEFAULT_PER_PAGE if per_page <= 0
    [per_page, MAX_PER_PAGE].min
  end

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
