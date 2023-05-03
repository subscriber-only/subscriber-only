# frozen_string_literal: true

class HandleStripeEventJob < ApplicationJob
  queue_as :default

  def perform(stripe_event)
    StripeEvents.handle(stripe_event)
  end
end
