# frozen_string_literal: true

module Subscriptions
  extend self

  PLATFORM_FEE = 10

  def subscribe(site, reader, billing_cycle)
    subscription = find_payable_subscription(site, reader, billing_cycle)
    if subscription
      stripe_subscription = fetch_stripe_subscription(subscription)
      return [:ok, subscription, stripe_subscription]
    end

    subscription = build_subscription(site, reader, billing_cycle)
    return [:error, subscription] if subscription.invalid?

    stripe_subscription = create_subscription(subscription)

    [:ok, subscription, stripe_subscription]
  end

  def cancel(subscription_id)
    subscription = Subscription.find(subscription_id)

    Stripe::Subscription.update(
      subscription.stripe_subscription_id,
      { cancel_at_period_end: true },
      { stripe_account: subscription.site.stripe_account_id },
    )

    subscription.update!(status: "user_canceled")

    [:ok, subscription]
  end

  private

  def find_payable_subscription(site, reader, billing_cycle)
    Subscription
      .find_by(site:, reader:, billing_cycle:, status: "payment_pending")
  end

  def fetch_stripe_subscription(subscription)
    Stripe::Subscription.retrieve(
      {
        id: subscription.stripe_subscription_id,
        expand: ["latest_invoice.payment_intent"],
      },
      { stripe_account: subscription.site.stripe_account_id },
    )
  end

  def build_subscription(site, reader, billing_cycle)
    # TODO: Should the Plan be passed somewhere so the customer doesn't end up
    #       paying a different price that the one they saw?
    Subscription.new(
      billing_cycle:,
      site:,
      reader:,
      plan: site.current_plan,
    )
  end

  def create_subscription(subscription)
    subscription.stripe_customer_id = find_or_create_customer(subscription)

    stripe_subscription = create_stripe_subscription(subscription)
    subscription.stripe_subscription_id = stripe_subscription.id

    subscription.save!

    stripe_subscription
  end

  def find_or_create_customer(subscription)
    find_existing_customer_id(subscription) || create_customer(subscription).id
  end

  def find_existing_customer_id(subscription)
    Subscription
      .order(created_at: :desc)
      .find_by(site: subscription.site, reader: subscription.reader)
      &.stripe_customer_id
  end

  def create_customer(subscription)
    Stripe::Customer.create(
      {
        email: subscription.reader.email,
        metadata: {
          user_id: subscription.reader.user.id,
          reader_id: subscription.reader.id,
        },
      },
      { stripe_account: subscription.site.stripe_account_id },
    )
  end

  def create_stripe_subscription(subscription)
    Stripe::Subscription.create(
      {
        customer: subscription.stripe_customer_id,
        items: [{ price: find_price(subscription) }],
        payment_behavior: "default_incomplete",
        payment_settings: { save_default_payment_method: "on_subscription" },
        application_fee_percent: PLATFORM_FEE,
        expand: ["latest_invoice.payment_intent"],
      },
      { stripe_account: subscription.site.stripe_account_id },
    )
  end

  def find_price(subscription)
    subscription
      .plan
      .public_send("stripe_#{subscription.billing_cycle}_price_id")
  end
end
