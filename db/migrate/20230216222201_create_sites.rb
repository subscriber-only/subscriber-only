# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[7.0]
  def change
    create_enum :site_merchant_account_status, %w[
      details_pending
      charges_enabled
    ]

    create_table :sites do |t|
      t.references :user,
                   null: false,
                   foreign_key: true,
                   index: { unique: true }
      t.string :name, null: false
      t.string :domain, null: false
      t.string :public_token, null: false, index: { unique: true }
      t.string :secret_token, null: false, index: { unique: true }
      t.enum :merchant_account_status,
             enum_type: "site_merchant_account_status",
             null: false,
             default: "details_pending"
      t.string :stripe_account_id, null: false, default: ""
      t.timestamps
    end
  end
end
