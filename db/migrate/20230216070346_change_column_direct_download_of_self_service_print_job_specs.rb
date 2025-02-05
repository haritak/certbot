class ChangeColumnDirectDownloadOfSelfServicePrintJobSpecs < ActiveRecord::Migration[7.0]
  def change

    change_column :self_service_print_job_specs, :direct_download, :boolean, default: true

  end
end
