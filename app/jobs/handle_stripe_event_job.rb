# typed: strict
# frozen_string_literal: true

class HandleStripeEventJob < ApplicationJob
  queue_as :default

  sig { params(stripe_event: Stripe::Event).void }
  def perform(stripe_event)
    StripeEvents.handle(stripe_event)
  end
end
