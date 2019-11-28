class CreateSuscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :suscriptions do |t|
      t.integer :name
      t.boolean :status
      t.integer :hours
      t.string :observations
      t.string :rooms
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
