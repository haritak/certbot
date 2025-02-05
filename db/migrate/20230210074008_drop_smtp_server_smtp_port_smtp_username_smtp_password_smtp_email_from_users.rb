class DropSmtpServerSmtpPortSmtpUsernameSmtpPasswordSmtpEmailFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :smtp_server
    remove_column :users, :smtp_port
    remove_column :users, :smtp_username
    remove_column :users, :smtp_password
    remove_column :users, :smtp_email
  end
end
