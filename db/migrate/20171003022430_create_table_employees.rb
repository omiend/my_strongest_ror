class CreateTableEmployees < ActiveRecord::Migration[5.1]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :first_kana_name
      t.string :last_kana_name
      t.integer :age
      t.string :avatar

      t.timestamps null: false
    end
  end
end
