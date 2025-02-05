# == Schema Information
#
# Table name: self_service_print_jobs
#
#  id                             :bigint           not null, primary key
#  field_values                   :text(65535)
#  recipient                      :string(255)
#  user_specific_page             :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  self_service_print_job_spec_id :bigint           not null
#
# Indexes
#
#  index_self_service_print_jobs_on_self_service_print_job_spec_id  (self_service_print_job_spec_id)
#
# Foreign Keys
#
#  fk_rails_...  (self_service_print_job_spec_id => self_service_print_job_specs.id)
#
class SelfServicePrintJob < ApplicationRecord
  belongs_to :self_service_print_job_spec
  has_many :self_service_generated_files

  before_destroy :delete_files

  def user
    self.self_service_print_job_spec.user
  end

  private

  def delete_files
    #
    # ExecuteSelfServicePrintJob
    # creates some more files for every SelfServicePrintJob
    #
    #

    self.self_service_generated_files.destroy_all

    jobSpec = self.self_service_print_job_spec.print_job_spec
    user_email = jobSpec.user.email
    odt_file = "#{jobSpec.id}.odt"
    csv_file = "#{jobSpec.id}.csv"

    work_dir = "#{Rails.root}/self_generated_files/#{user_email}/#{jobSpec.id}" 
    work_dir = "#{work_dir}/#{self.user_specific_page}"

    copy_of_odt = "#{work_dir}/#{odt_file}"
    FileUtils.remove_file( copy_of_odt ) if File.exist? copy_of_odt
    FileUtils.remove_dir( work_dir ) if File.exist? work_dir
  end
end
