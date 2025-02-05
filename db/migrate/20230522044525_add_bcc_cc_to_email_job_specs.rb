class AddBccCcToEmailJobSpecs < ActiveRecord::Migration[7.0]
  def change
    add_column :email_job_specs, :bcc, :string
    add_column :email_job_specs, :cc, :string
  end
end
