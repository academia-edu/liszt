class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :name
      t.integer :group_id
      t.boolean :is_male

      t.timestamps
    end
  end
end
