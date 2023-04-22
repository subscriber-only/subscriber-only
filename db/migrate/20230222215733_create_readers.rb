# frozen_string_literal: true

class CreateReaders < ActiveRecord::Migration[7.0]
  def change
    create_table :readers do |t|
      t.references :user,
                   null: false,
                   foreign_key: true,
                   index: { unique: true }
      t.timestamps
    end
  end
end
