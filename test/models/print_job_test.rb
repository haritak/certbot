# == Schema Information
#
# Table name: print_jobs
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  execution_job_id  :bigint
#  print_job_spec_id :bigint           not null
#
# Indexes
#
#  index_print_jobs_on_print_job_spec_id  (print_job_spec_id)
#
# Foreign Keys
#
#  fk_rails_...  (print_job_spec_id => print_job_specs.id)
#
require "test_helper"

class PrintJobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
