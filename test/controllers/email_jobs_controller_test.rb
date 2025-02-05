require "test_helper"

class EmailJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @email_job = email_jobs(:one)
  end

  test "should get index" do
    get email_jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_email_job_url
    assert_response :success
  end

  test "should create email_job" do
    assert_difference("EmailJob.count") do
      post email_jobs_url, params: { email_job: { csv_entry: @email_job.csv_entry, email_job_spec_id: @email_job.email_job_spec_id, execution_job_id: @email_job.execution_job_id, retries_left: @email_job.retries_left, status: @email_job.status } }
    end

    assert_redirected_to email_job_url(EmailJob.last)
  end

  test "should show email_job" do
    get email_job_url(@email_job)
    assert_response :success
  end

  test "should get edit" do
    get edit_email_job_url(@email_job)
    assert_response :success
  end

  test "should update email_job" do
    patch email_job_url(@email_job), params: { email_job: { csv_entry: @email_job.csv_entry, email_job_spec_id: @email_job.email_job_spec_id, execution_job_id: @email_job.execution_job_id, retries_left: @email_job.retries_left, status: @email_job.status } }
    assert_redirected_to email_job_url(@email_job)
  end

  test "should destroy email_job" do
    assert_difference("EmailJob.count", -1) do
      delete email_job_url(@email_job)
    end

    assert_redirected_to email_jobs_url
  end
end
