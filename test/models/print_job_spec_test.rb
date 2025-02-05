# == Schema Information
#
# Table name: print_job_specs
#
#  id          :bigint           not null, primary key
#  comment     :text(65535)
#  messages    :text(65535)
#  status      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  csv_file_id :bigint           not null
#  odt_file_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_print_job_specs_on_csv_file_id  (csv_file_id)
#  index_print_job_specs_on_odt_file_id  (odt_file_id)
#  index_print_job_specs_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (csv_file_id => csv_files.id)
#  fk_rails_...  (odt_file_id => odt_files.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class PrintJobSpecTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
