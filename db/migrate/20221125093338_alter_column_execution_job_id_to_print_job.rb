class AlterColumnExecutionJobIdToPrintJob < ActiveRecord::Migration[7.0]
  def change
    change_column :print_jobs, :execution_job_id, :bigint 
  end
end
