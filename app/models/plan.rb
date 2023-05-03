# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: plans
#
#  id                      :bigint           not null, primary key
#  monthly_price_cents     :integer          default(0), not null
#  monthly_price_currency  :string           default("USD"), not null
#  name                    :string           default(""), not null
#  yearly_price_cents      :integer          default(0), not null
#  yearly_price_currency   :string           default("USD"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  site_id                 :bigint           not null
#  stripe_monthly_price_id :string           default(""), not null
#  stripe_product_id       :string           default(""), not null
#  stripe_yearly_price_id  :string           default(""), not null
#
# Indexes
#
#  index_plans_on_site_id  (site_id)
#
# Foreign Keys
#
#  fk_rails_...  (site_id => sites.id)
#
class Plan < ApplicationRecord
  SUPPORTED_CURRENCIES = T.let(%w[USD EUR CAD].freeze, T::Array[String])

  monetize :monthly_price_cents, numericality: { greater_than: 0 }
  monetize :yearly_price_cents, numericality: { greater_than: 0 }

  belongs_to :site

  validates :monthly_price_currency,
            presence: true,
            inclusion: { in: Plan::SUPPORTED_CURRENCIES }
  validates :yearly_price_currency,
            presence: true,
            inclusion: { in: Plan::SUPPORTED_CURRENCIES }

  sig do
    returns({
      monthly: { amount: Integer, currency: String },
      yearly: { amount: Integer, currency: String },
    })
  end
  def price_lookup
    @price_lookup ||= {
      monthly: {
        amount: monthly_price_cents,
        currency: monthly_price_currency,
      },
      yearly: {
        amount: yearly_price_cents,
        currency: yearly_price_currency,
      },
    }
  end
end
