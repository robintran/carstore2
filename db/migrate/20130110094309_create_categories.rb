class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.integer :lft
      t.integer :rgt
      t.integer :depth
      t.string :link

      t.timestamps
    end
  end
end
