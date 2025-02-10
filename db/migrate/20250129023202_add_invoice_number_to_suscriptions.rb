class AddInvoiceNumberToSuscriptions < ActiveRecord::Migration[8.0]
  def change
    add_column :suscriptions, :invoice_number, :text
  end
end
