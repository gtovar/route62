class Link < ApplicationRecord
  belongs_to :user, optional: true
  has_many :visits, dependent: :destroy

  validates :long_url, presence: true
  validate :long_url_must_be_http_or_https

  validates :slug, uniqueness: true, allow_nil: true

  def assign_unique_slug!
    update!(slug: ShortenerService.encode(id))
  end

  private

  def long_url_must_be_http_or_https
    return if long_url.blank?
    return if long_url.start_with?("http://", "https://")

    errors.add(:long_url, "Invalid URL format")
  end
end
