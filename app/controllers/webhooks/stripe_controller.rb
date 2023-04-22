# frozen_string_literal: true

class Webhooks::StripeController < ActionController::API
  def create
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        request.body.read,
        request.headers["Stripe-Signature"],
        Rails.application.credentials.dig(:stripe, :webhook_signing_secret),
      )
    rescue Stripe::SignatureVerificationError
      head :bad_request
      return
    end

    if StripeEvents.handles?(event.type)
      HandleStripeEventJob.perform_later(event)
    end

    head :ok
  end
end
