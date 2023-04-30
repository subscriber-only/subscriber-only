# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id                     :bigint           not null, primary key
#  billing_cycle          :enum             not null
#  renews_on              :datetime
#  starts_on              :datetime
#  status                 :enum             default("payment_pending"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  plan_id                :bigint           not null
#  reader_id              :bigint           not null
#  site_id                :bigint           not null
#  stripe_customer_id     :string           default(""), not null
#  stripe_subscription_id :string           default(""), not null
#
# Indexes
#
#  index_subscriptions_on_plan_id    (plan_id)
#  index_subscriptions_on_reader_id  (reader_id)
#  index_subscriptions_on_site_id    (site_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (reader_id => readers.id)
#  fk_rails_...  (site_id => sites.id)
#
class Subscription < ApplicationRecord
  scope :technically_active, -> { where(status: %w[active user_canceled]) }

  enum :billing_cycle,
       monthly: "monthly",
       yearly: "yearly"

  enum :status,
       # The Reader has a pending invoice. If the invoice isn't paid and
       # it is the first payment, the Subscription will become
       # failed_to_activate. If a renewal invoice is left unpaid, the
       # Subscription will become inactive.
       payment_pending: "payment_pending",
       # The Reader has full access to the Site.
       active: "active",
       # The Reader has an active Subscription but has decided to cancel
       # it. It won't renew at the end of the billing cycle and it will
       # then become inactive.
       #
       # TODO: Remove this state. It should just be 'active'. Add a
       # 'cancels_at' date or something, instead.
       user_canceled: "user_canceled",
       # FINAL - The Reader previously had access to the Site but no
       # longer has.
       # If they want to regain access, a new Subscription must be created.
       inactive: "inactive",
       # FINAL - The Reader never paid the first invoice and, as such,
       # never had access to the Site.
       failed_to_activate: "failed_to_activate"

  belongs_to :reader
  belongs_to :site
  belongs_to :plan

  validates :billing_cycle, presence: true
  validate :ensure_not_already_subscribed

  after_destroy_commit :cancel_subscription, if: -> { Rails.env.development? }

  def stripe_subscription
    Stripe::Subscription.retrieve(
      stripe_subscription_id,
      { stripe_account: site.stripe_account_id },
    )
  end

  private

  def ensure_not_already_subscribed
    return unless Subscription.where(site:, reader:).technically_active.exists?

    errors.add(:base, :invalid,
               message: "Active or payment_pending Subscription already exists")
  end

  def cancel_subscription
    Stripe::Subscription.cancel(
      stripe_subscription_id,
      {},
      { stripe_account: site.stripe_account_id },
    )
  end
end
