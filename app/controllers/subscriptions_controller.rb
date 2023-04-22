# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  prepend_before_action :authenticate_with_sign_up!, only: :new

  before_action :set_site_and_reader, only: %i[new confirm]
  before_action :redirect_on_status, only: :new

  def index
    @subscriptions = current_user.reader
      .subscriptions
      .where.not(status: %w[inactive failed_to_activate])
  end

  def new
    not_found if current_user.site == @site
  end

  def edit
    @subscription = Subscription.find(params[:id])
  end

  def destroy
    Subscriptions.cancel(params[:id])
    redirect_to action: :edit, id: params[:id]
  end

  def confirm; end

  private

  def set_site_and_reader
    @site = Site.find_by!(public_token: params[:public_token])
    @reader = current_user.reader
  end

  def redirect_on_status
    subscription = Subscription
      .where(site: @site, reader: @reader)
      .order(created_at: :desc)
      .first
    return unless subscription

    case subscription.status
    when "active"
      redirect_to(
        params[:referer_url] || edit_subscription(subscription),
        allow_other_host: true,
      )
    when "user_canceled"
      redirect_to action: :edit, id: subscription.id
    end
  end
end
