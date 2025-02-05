class CreateEmailJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :email_jobs do |t|
      t.references :email_job_spec, null: false, foreign_key: true
      t.bigint :execution_job_id
      t.string :csv_entry, limit: 2000 #not tested!
      t.string :status
      t.integer :retries_left

      t.timestamps
    end
  end
end
