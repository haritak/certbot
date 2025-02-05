class AddStatusToSelfServiceGeneratedFiles < ActiveRecord::Migration[7.0]
  def change
    add_column :self_service_generated_files, :status, :string
  end
end
