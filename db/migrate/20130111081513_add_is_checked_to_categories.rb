class AddIsCheckedToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :is_checked, :boolean, :default => false
  end
end
