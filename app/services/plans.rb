# frozen_string_literal: true

module Plans
  extend self

  NAME = "Standard Subscription"

  def update_plan(plan_params, site)
    plan = Plan.new(plan_params.merge(site:, name: NAME))
    return [:error, plan] unless plan.valid?

    return [:ok, site.current_plan] if same_prices?(plan, site.current_plan)

    create_stripe_product(plan, site)
    create_stripe_prices(plan, site)
    disable_current_prices(site)

    plan.save!
    site.reload

    [:ok, plan]
  end

  private

  def same_prices?(new_plan, current_plan)
    return false if current_plan.blank?

    n = new_plan
    c = current_plan

    [
      n.monthly_price_currency == c.monthly_price_currency,
      n.yearly_price_currency == c.yearly_price_currency,
      n.monthly_price_cents == c.monthly_price_cents,
      n.yearly_price_cents == c.yearly_price_cents,
    ].all?
  end

  def create_stripe_product(plan, site)
    product_id = if site.current_plan.present?
      site.current_plan.stripe_product_id
    else
      product = Stripe::Product.create(
        { name: plan.name },
        { stripe_account: site.stripe_account_id },
      )

      product.id
    end

    plan.stripe_product_id = product_id
  end

  def create_stripe_prices(plan, site)
    monthly_price = Stripe::Price.create(
      {
        product: plan.stripe_product_id,
        unit_amount: plan.monthly_price_cents,
        currency: plan.monthly_price_currency,
        recurring: { interval: "month" },
        lookup_key: "monthly_standard_subscription",
      },
      { stripe_account: site.stripe_account_id },
    )
    yearly_price = Stripe::Price.create(
      {
        product: plan.stripe_product_id,
        unit_amount: plan.yearly_price_cents,
        currency: plan.yearly_price_currency,
        recurring: { interval: "year" },
        lookup_key: "yearly_standard_subscription",
      },
      { stripe_account: site.stripe_account_id },
    )

    plan.stripe_monthly_price_id = monthly_price.id
    plan.stripe_yearly_price_id = yearly_price.id
  end

  def disable_current_prices(site)
    return if site.current_plan.blank?

    Stripe::Price.update(
      site.current_plan.stripe_monthly_price_id,
      { active: false },
      { stripe_account: site.stripe_account_id },
    )
    Stripe::Price.update(
      site.current_plan.stripe_yearly_price_id,
      { active: false },
      { stripe_account: site.stripe_account_id },
    )
  end
end
