class CreateAccessTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :access_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code, index: { unique: true }
      t.string :token, null: false, index: { unique: true }
      t.datetime :last_used_on
      t.timestamps
    end
  end
end
