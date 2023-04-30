# typed: false
# frozen_string_literal: true

class Api::Internal::SubscriptionsController < ActionController::API
  before_action :authenticate_user!
  before_action :set_site_and_reader

  def create
    ret = Subscriptions.subscribe(@site, @reader, params[:billing_cycle])

    case ret
    in [:ok, subscription, stripe_subscription]
      render status: :created, json: {
        subscription_id: subscription.id,
        client_secret:
          stripe_subscription.latest_invoice.payment_intent.client_secret,
      }
    in [:error, subscription]
      render status: :unprocessable_entity, json: {
        message: subscription.errors.full_messages.first,
      }
    end
  end

  private

  def set_site_and_reader
    @site = Site.find_by!(public_token: params[:public_token])
    @reader = current_user.reader
  end
end
