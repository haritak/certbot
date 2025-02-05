class CreateSelfServiceGeneratedFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :self_service_generated_files do |t|
      t.references :self_service_print_job, null: false, foreign_key: true
      t.string :path, limit: 500

      t.timestamps
    end
  end
end
