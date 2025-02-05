class CreatePrintJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :print_jobs do |t|
      t.references :print_job_spec, null: false, foreign_key: true

      t.timestamps
    end
  end
end
