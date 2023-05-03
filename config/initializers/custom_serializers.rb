# frozen_string_literal: true

require "stripe_object_serializer"

Rails.application.config.active_job.custom_serializers << StripeObjectSerializer
