# frozen_string_literal: true

class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.references :site, null: false, foreign_key: true
      t.string :name, null: false, default: ""
      t.monetize :monthly_price, null: false
      t.monetize :yearly_price, null: false
      t.string :stripe_product_id, null: false, default: ""
      t.string :stripe_monthly_price_id, null: false, default: ""
      t.string :stripe_yearly_price_id, null: false, default: ""
      t.timestamps
    end
  end
end
