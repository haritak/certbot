class CreatePrintJobSpecs < ActiveRecord::Migration[7.0]
  def change
    create_table :print_job_specs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :odt_file, null: false, foreign_key: true
      t.references :csv_file, null: false, foreign_key: true
      t.string :status
      t.text :messages
      t.text :comment

      t.timestamps
    end
  end
end
