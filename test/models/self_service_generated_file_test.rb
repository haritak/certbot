# == Schema Information
#
# Table name: self_service_generated_files
#
#  id                        :bigint           not null, primary key
#  path                      :string(500)
#  status                    :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  self_service_print_job_id :bigint           not null
#
# Indexes
#
#  index_self_service_generated_files_on_path                       (path)
#  index_self_service_generated_files_on_self_service_print_job_id  (self_service_print_job_id)
#  index_self_service_generated_files_on_status                     (status)
#
# Foreign Keys
#
#  fk_rails_...  (self_service_print_job_id => self_service_print_jobs.id)
#
require "test_helper"

class SelfServiceGeneratedFileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
