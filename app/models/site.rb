# frozen_string_literal: true

# == Schema Information
#
# Table name: sites
#
#  id                :bigint           not null, primary key
#  charges_enabled   :boolean          default(FALSE), not null
#  details_submitted :boolean          default(FALSE), not null
#  domain            :string           not null
#  name              :string           not null
#  payouts_enabled   :boolean          default(FALSE), not null
#  public_token      :string           not null
#  secret_token      :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  stripe_account_id :string           default(""), not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_sites_on_domain        (domain) UNIQUE
#  index_sites_on_public_token  (public_token) UNIQUE
#  index_sites_on_secret_token  (secret_token) UNIQUE
#  index_sites_on_user_id       (user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Site < ApplicationRecord
  DOMAIN_REGEX =
    /\A[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z]{2,})+\z/

  has_secure_token :secret_token, length: 32

  belongs_to :user
  has_many :plans, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_one :current_plan,
          -> { order(created_at: :desc) },
          class_name: "Plan",
          inverse_of: :site,
          dependent: :destroy

  validates :name, presence: true
  validates :domain, presence: true, uniqueness: true
  validates :domain,
            format: { with: Site::DOMAIN_REGEX, message: "is invalid" },
            if: -> { Rails.env.production? }

  before_create :generate_public_token

  delegate :email, to: :user
  delegate :price_lookup, to: :current_plan

  def basic_info?
    name.present? && domain.present?
  end

  def payouts?
    charges_enabled? && payouts_enabled?
  end

  def setup?
    basic_info? && details_submitted? && current_plan.present?
  end

  private

  def generate_public_token
    self.public_token = SecureRandom.base58(16)
  end
end
