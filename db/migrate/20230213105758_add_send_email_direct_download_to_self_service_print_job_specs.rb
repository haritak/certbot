class AddSendEmailDirectDownloadToSelfServicePrintJobSpecs < ActiveRecord::Migration[7.0]
  def change
    add_column :self_service_print_job_specs, :send_email, :boolean, default: true
    add_column :self_service_print_job_specs, :direct_download, :boolean,  default: false
  end
end
