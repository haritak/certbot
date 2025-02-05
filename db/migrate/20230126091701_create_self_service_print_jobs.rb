class CreateSelfServicePrintJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :self_service_print_jobs do |t|
      t.references :self_service_print_job_spec, null: false, foreign_key: true
      t.text :field_values
      t.string :user_specific_page

      t.timestamps
    end
  end
end
