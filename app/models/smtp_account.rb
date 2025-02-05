# == Schema Information
#
# Table name: smtp_accounts
#
#  id                                                                         :bigint           not null, primary key
#  description                                                                :string(255)
#  from                                                                       :string(255)
#  password(Extra large for encrypted content)                                :string(500)
#  port                                                                       :integer
#  server                                                                     :string(255)
#  type(STI (Single Table Inheritance for SmtpAccount and SystemSmtpAccount)) :string(255)
#  username(Extra large for encrypted content)                                :string(500)
#  created_at                                                                 :datetime         not null
#  updated_at                                                                 :datetime         not null
#  user_id(Owner of this entry)                                               :bigint           not null
#
# Indexes
#
#  index_smtp_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class SmtpAccount < ApplicationRecord
  # https://guides.rubyonrails.org/active_record_encryption.html#declaration-of-encrypted-attributes

  belongs_to :user
  encrypts :password, :username, :server, :from

  def long_description
    "#{self.from} #{self.description} #{self.server} (#{self.type})"
  end

  def to_s
    long_description
  end

  def custom_smtp_account?
    not self.is_a?( SystemSmtpAccount )
  end
end
