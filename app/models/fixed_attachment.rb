# == Schema Information
#
# Table name: fixed_attachments
#
#  id             :bigint           not null, primary key
#  email_filename :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_fixed_attachments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class FixedAttachment < ApplicationRecord
  has_one_attached :fixed

  belongs_to :email_job_spec, optional: true
  belongs_to :user
end
