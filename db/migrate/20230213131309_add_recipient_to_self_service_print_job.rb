class AddRecipientToSelfServicePrintJob < ActiveRecord::Migration[7.0]
  def change
    add_column :self_service_print_jobs, :recipient, :string
  end
end
