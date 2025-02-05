# == Schema Information
#
# Table name: generated_files
#
#  id                :bigint           not null, primary key
#  path              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  print_job_spec_id :bigint           not null
#
# Indexes
#
#  index_generated_files_on_path               (path) UNIQUE
#  index_generated_files_on_print_job_spec_id  (print_job_spec_id)
#
# Foreign Keys
#
#  fk_rails_...  (print_job_spec_id => print_job_specs.id)
#
require "test_helper"

class GeneratedFileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
