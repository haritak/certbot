require "test_helper"

class EmailJobSpecsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email_job_spec = email_job_specs(:one)
  end

  test "should get index" do
    get email_job_specs_url
    assert_response :success
  end

  test "should get new" do
    get new_email_job_spec_url
    assert_response :success
  end

  test "should create email_job_spec" do
    assert_difference("EmailJobSpec.count") do
      post email_job_specs_url, params: { email_job_spec: { attachment_pattern: @email_job_spec.attachment_pattern, csv_entries: @email_job_spec.csv_entries, print_job_spec_id: @email_job_spec.print_job_spec_id } }
    end

    assert_redirected_to email_job_spec_url(EmailJobSpec.last)
  end

  test "should show email_job_spec" do
    get email_job_spec_url(@email_job_spec)
    assert_response :success
  end

  test "should get edit" do
    get edit_email_job_spec_url(@email_job_spec)
    assert_response :success
  end

  test "should update email_job_spec" do
    patch email_job_spec_url(@email_job_spec), params: { email_job_spec: { attachment_pattern: @email_job_spec.attachment_pattern, csv_entries: @email_job_spec.csv_entries, print_job_spec_id: @email_job_spec.print_job_spec_id } }
    assert_redirected_to email_job_spec_url(@email_job_spec)
  end

  test "should destroy email_job_spec" do
    assert_difference("EmailJobSpec.count", -1) do
      delete email_job_spec_url(@email_job_spec)
    end

    assert_redirected_to email_job_specs_url
  end
end
