class AddSmtpEmailToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :smtp_email, :string
  end
end
