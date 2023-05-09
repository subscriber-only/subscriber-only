# frozen_string_literal: true

class AuthorizedUrlsController < ApplicationController
  def create
    head status: :unprocessable_entity and return if params[:return_to].blank?

    return_to = AccessTokens.authorize_url(params[:return_to], current_user)
    redirect_to return_to, allow_other_host: true
  end
end
