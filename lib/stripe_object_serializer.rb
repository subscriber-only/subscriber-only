# frozen_string_literal: true

class StripeObjectSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize?(argument)
    argument.is_a?(Stripe::StripeObject)
  end

  def serialize(stripe_object)
    super(stripe_object.to_hash)
  end

  def deserialize(hash)
    Stripe::Util.convert_to_stripe_object(hash.deep_symbolize_keys)
  end
end
