class AddExpiresAtToSuscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :suscriptions, :expires_at, :date
  end
end
