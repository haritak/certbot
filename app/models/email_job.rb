# == Schema Information
#
# Table name: email_jobs
#
#  id                :bigint           not null, primary key
#  csv_entry         :string(2000)
#  retries_left      :integer
#  status            :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  email_job_spec_id :bigint           not null
#  execution_job_id  :bigint
#
# Indexes
#
#  index_email_jobs_on_email_job_spec_id  (email_job_spec_id)
#
# Foreign Keys
#
#  fk_rails_...  (email_job_spec_id => email_job_specs.id)
#
class EmailJob < ApplicationRecord
  belongs_to :email_job_spec

  scope :failed,  -> { where("status LIKE '#{EmailJobSpec::STATUS[ :internal_error ]}%' ") }

  def user
    self.email_job_spec.user
  end
end
