# frozen_string_literal: true

class CreateSites < ActiveRecord::Migration[7.0]
  def change
    create_table :sites do |t|
      t.references :user,
                   null: false,
                   foreign_key: true,
                   index: { unique: true }
      t.string :name, null: false
      t.string :domain, null: false, index: { unique: true }
      t.string :public_token, null: false, index: { unique: true }
      t.string :secret_token, null: false, index: { unique: true }
      t.string :stripe_account_id, null: false, default: ""
      t.boolean :details_submitted, null: false, default: false
      t.boolean :charges_enabled, null: false, default: false
      t.boolean :payouts_enabled, null: false, default: false
      t.timestamps
    end
  end
end
