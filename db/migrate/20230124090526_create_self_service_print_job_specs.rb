# Mysql2::Error: BLOB, TEXT, GEOMETRY or JSON column 'field_names' can't have a default value
# /home/haritak/Coding/certificate_generator/certPrintShop/db/migrate/20230124090526_create_self_service_print_job_specs.rb:3:in `change'
class CreateSelfServicePrintJobSpecs < ActiveRecord::Migration[7.0]
  def change
    create_table :self_service_print_job_specs do |t|
      t.references :print_job_spec, null: false, foreign_key: true
      t.string     :title, null: false
      t.string     :secret_url_part, unique: true, comment: "Used to create a url to be given to clients"
      t.boolean    :active, comment: "Whether accepting clients or not", default: false
      t.text       :field_names
      t.boolean    :validate_client_email, comment: "Whether to verify that the email exists into csv file",
        default: false
      t.timestamps
    end
  end
end
