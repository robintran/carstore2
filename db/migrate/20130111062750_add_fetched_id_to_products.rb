class AddFetchedIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :fetched_id, :integer
  end
end
