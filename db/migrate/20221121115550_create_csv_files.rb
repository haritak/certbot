class CreateCsvFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_files do |t|
      t.string :filename, limit: 255
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
