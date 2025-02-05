require "test_helper"

class PrintJobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @print_job = print_jobs(:one)
  end

  test "should get index" do
    get print_jobs_url
    assert_response :success
  end

  test "should get new" do
    get new_print_job_url
    assert_response :success
  end

  test "should create print_job" do
    assert_difference("PrintJob.count") do
      post print_jobs_url, params: { print_job: { print_job_spec_id: @print_job.print_job_spec_id } }
    end

    assert_redirected_to print_job_url(PrintJob.last)
  end

  test "should show print_job" do
    get print_job_url(@print_job)
    assert_response :success
  end

  test "should get edit" do
    get edit_print_job_url(@print_job)
    assert_response :success
  end

  test "should update print_job" do
    patch print_job_url(@print_job), params: { print_job: { print_job_spec_id: @print_job.print_job_spec_id } }
    assert_redirected_to print_job_url(@print_job)
  end

  test "should destroy print_job" do
    assert_difference("PrintJob.count", -1) do
      delete print_job_url(@print_job)
    end

    assert_redirected_to print_jobs_url
  end
end
