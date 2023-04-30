# typed: false
# frozen_string_literal: true

module StripeEvents
  extend self

  HANDLED_EVENTS = [
    "account.updated",
    "customer.subscription.created",
    "customer.subscription.deleted",
    "customer.subscription.updated",
  ].freeze

  def handles?(event_type)
    HANDLED_EVENTS.include?(event_type)
  end

  def handle(event)
    method_name = event.type.gsub(".", "_")
    send(method_name, event.data.object)
  end

  private

  def account_updated(account)
    site = Site.find_by(stripe_account_id: account.id)
    return if site.nil?

    return unless account.details_submitted && account.charges_enabled

    site.update!(merchant_account_status: "charges_enabled")
  end

  def customer_subscription_created(stripe_subscription)
    customer_subscription_updated(stripe_subscription)
  end

  def customer_subscription_deleted(stripe_subscription)
    customer_subscription_updated(stripe_subscription)
  end

  def customer_subscription_updated(stripe_subscription)
    subscription = Subscription.find_by(
      stripe_subscription_id: stripe_subscription.id,
    )
    return if subscription.nil?

    subscription.status = case stripe_subscription.status
    when "active"
      if stripe_subscription.cancel_at_period_end
        "user_canceled"
      else
        "active"
      end
    when "incomplete", "past_due"
      "payment_pending"
    when "canceled", "unpaid"
      "inactive"
    when "incomplete_expired"
      "failed_to_activate"
    end

    subscription.update!(
      starts_on: Time.zone.at(stripe_subscription.current_period_start),
      renews_on: Time.zone.at(stripe_subscription.current_period_end),
    )
  end
end
