class CreateGeneratedFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :generated_files do |t|
      t.references :print_job_spec, null: false, foreign_key: true
      t.string :path

      t.timestamps
    end
    add_index :generated_files, :path, unique: true
  end
end
