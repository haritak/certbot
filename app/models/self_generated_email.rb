# == Schema Information
#
# Table name: self_generated_emails
#
#  id                             :bigint           not null, primary key
#  attachment_path                :string(500)
#  recipient                      :string(255)
#  status                         :string(255)
#  values                         :text(65535)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  self_service_print_job_spec_id :bigint           not null
#
# Indexes
#
#  index_self_generated_emails_on_self_service_print_job_spec_id  (self_service_print_job_spec_id)
#  index_self_generated_emails_on_status                          (status)
#
# Foreign Keys
#
#  fk_rails_...  (self_service_print_job_spec_id => self_service_print_job_specs.id)
#
class SelfGeneratedEmail < ApplicationRecord
  belongs_to :self_service_print_job_spec

  scope :succesfull, ->{ where( status: "SENT" ) }
  scope :failed, ->{ where.not( status: "SENT" ) }

  def to_s
    "#{self.self_service_print_job_spec.id} #{self.values} #{self.recipient} #{self.attachment_path} #{self.status}"
  end
end
