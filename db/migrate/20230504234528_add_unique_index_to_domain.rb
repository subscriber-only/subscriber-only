class AddUniqueIndexToDomain < ActiveRecord::Migration[7.0]
  def change
    add_index :sites, :domain, unique: true
  end
end
