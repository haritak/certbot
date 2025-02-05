class AddColumnExecutionJobIdToPrintJob < ActiveRecord::Migration[7.0]
  def change
    add_column :print_jobs, :execution_job_id, :integer
  end
end
