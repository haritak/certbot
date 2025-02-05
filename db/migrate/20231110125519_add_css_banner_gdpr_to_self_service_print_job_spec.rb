class AddCssBannerGdprToSelfServicePrintJobSpec < ActiveRecord::Migration[7.0]
  def change
    add_column :self_service_print_job_specs, :css, :string, default: "default.css"
    add_column :self_service_print_job_specs, :banner, :string, default: "banner.jpg"
    add_column :self_service_print_job_specs, :gdpr, :string, default: "gdpr.html"
  end
end
