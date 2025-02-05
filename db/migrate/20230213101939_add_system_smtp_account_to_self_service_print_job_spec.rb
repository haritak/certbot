class AddSystemSmtpAccountToSelfServicePrintJobSpec < ActiveRecord::Migration[7.0]
  def change
    add_reference :self_service_print_job_specs, :smtp_account, null: true, foreign_key: true
  end
end
