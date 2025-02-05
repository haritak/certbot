class AddColumnStatusToEmailJobSpec < ActiveRecord::Migration[7.0]
  def change
    add_column :email_job_specs, :status, :string
  end
end
