# frozen_string_literal: true

class MerchantAccountsController < ApplicationController
  def create
    setup_url = MerchantAccounts.generate_setup_link(current_user.site)
    redirect_to setup_url, allow_other_host: true
  end
end
