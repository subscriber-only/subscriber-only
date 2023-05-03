# typed: strict
# frozen_string_literal: true

class MerchantAccountsController < ApplicationController
  sig { void }
  def create
    setup_url = MerchantAccounts.generate_setup_link(T.must(current_user.site))
    redirect_to setup_url, allow_other_host: true
  end
end
