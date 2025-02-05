class AddServerPortSmtpUsernameSmtpPasswordToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :smtp_server, :string
    add_column :users, :smtp_port, :integer
    add_column :users, :smtp_username, :string
    add_column :users, :smtp_password, :string
  end
end
