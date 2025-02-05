class AddUserToFixedAttachments < ActiveRecord::Migration[7.0]
  def change
    add_reference :fixed_attachments, :user, null: false, foreign_key: true
  end
end
