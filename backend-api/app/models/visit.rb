class Visit < ApplicationRecord
  belongs_to :link

  validates :ip_address, presence: true
  validates :user_agent, presence: true
  validates :visited_at, presence: true
end
