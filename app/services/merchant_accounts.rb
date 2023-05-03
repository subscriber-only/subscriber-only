# typed: strict
# frozen_string_literal: true

module MerchantAccounts
  extend self

  delegate :url_helpers, to: "Rails.application.routes", private: true

  sig { params(site: Site).returns(String) }
  def generate_setup_link(site)
    create_account(site)
    generate_account_link(site)
  end

  private

  sig { params(site: Site).returns(String) }
  def generate_account_link(site)
    account_link = Stripe::AccountLink.create(
      {
        account: site.stripe_account_id,
        refresh_url: url_helpers.edit_site_url,
        return_url: url_helpers.edit_site_url,
        type: "account_onboarding",
      },
    )

    account_link.url
  end

  sig { params(site: Site).void }
  def create_account(site)
    return if site.stripe_account_id.present?

    account = Stripe::Account.create(
      {
        type: "standard",
        email: site.email,
        business_profile: {
          url: Rails.env.development? ? "local.test" : site.domain,
        },
      },
    )
    site.update!(stripe_account_id: account.id)
  end
end
