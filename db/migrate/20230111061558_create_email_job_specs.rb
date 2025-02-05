class CreateEmailJobSpecs < ActiveRecord::Migration[7.0]
  def change
    create_table :email_job_specs do |t|
      t.references :print_job_spec, null: false, foreign_key: true
      t.string :csv_entries
      t.string :attachment_pattern

      t.timestamps
    end
  end
end
