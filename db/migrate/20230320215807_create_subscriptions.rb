# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_enum :subscription_billing_cycle, %w[monthly yearly]
    create_enum :subscription_status, %w[
      payment_pending
      active
      user_canceled
      inactive
      failed_to_activate
    ]

    create_table :subscriptions do |t|
      t.references :reader, null: false, foreign_key: true
      t.references :site, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.enum :billing_cycle,
             enum_type: "subscription_billing_cycle",
             null: false
      t.enum :status,
             enum_type: "subscription_status",
             null: false,
             default: "payment_pending"
      t.datetime :starts_on
      t.datetime :renews_on
      t.string :stripe_customer_id, null: false, default: ""
      t.string :stripe_subscription_id, null: false, default: ""
      t.timestamps
    end
  end
end
