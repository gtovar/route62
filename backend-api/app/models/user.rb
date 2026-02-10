require "digest"

class User < ApplicationRecord
  attr_reader :plain_api_key

  has_secure_password
  has_many :links, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :api_key_digest, presence: true, uniqueness: true
  validates :api_key_last4, presence: true

  before_validation :normalize_email
  before_validation :ensure_api_key_material, on: :create

  def self.digest_api_key(raw_key)
    Digest::SHA256.hexdigest(raw_key.to_s)
  end

  def self.find_by_api_key(raw_key)
    digest = digest_api_key(raw_key)
    find_by(api_key_digest: digest)
  end

  def rotate_api_key!
    raw_key = self.class.generate_api_key
    update!(
      api_key_digest: self.class.digest_api_key(raw_key),
      api_key_last4: raw_key.last(4),
      api_key_rotated_at: Time.current
    )
    @plain_api_key = raw_key
    raw_key
  end

  private

  def ensure_api_key_material
    return if self.api_key_digest.present? && self.api_key_last4.present?

    raw_key = self.class.generate_api_key
    @plain_api_key = raw_key
    self.api_key_digest = self.class.digest_api_key(raw_key)
    self.api_key_last4 = raw_key.last(4)
    self.api_key_rotated_at = Time.current
  end

  def self.generate_api_key
    "rk_#{SecureRandom.hex(20)}"
  end

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end
