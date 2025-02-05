class CreateFixedAttachments < ActiveRecord::Migration[7.0]
  def change
    create_table :fixed_attachments do |t|
      t.string :email_filename

      t.timestamps
    end
  end
end
