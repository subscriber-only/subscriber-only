# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :site, null: false, foreign_key: true
      t.string :path, null: false
      t.string :title, null: false, default: ""
      t.text :content, null: false
      t.timestamps

      t.index %i[site_id path], unique: true
    end
  end
end
