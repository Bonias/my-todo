class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :title
      t.boolean :is_completed
      t.integer :order

      t.timestamps
    end
  end
end
