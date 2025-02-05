class CreateSelfGeneratedEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :self_generated_emails do |t|
      t.references :self_service_print_job_spec, null: false, foreign_key: true
      t.text :values
      t.string :recipient
      t.string :attachment_path, limit: 500
      t.string :status

      t.timestamps
    end
  end
end
