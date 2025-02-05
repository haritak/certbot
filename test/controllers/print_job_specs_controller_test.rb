require "test_helper"

class PrintJobSpecsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @print_job_spec = print_job_specs(:one)
  end

  test "should get index" do
    get print_job_specs_url
    assert_response :success
  end

  test "should get new" do
    get new_print_job_spec_url
    assert_response :success
  end

  test "should create print_job_spec" do
    assert_difference("PrintJobSpec.count") do
      post print_job_specs_url, params: { print_job_spec: { comment: @print_job_spec.comment, csv_file_id: @print_job_spec.csv_file_id, messages: @print_job_spec.messages, odt_file_id: @print_job_spec.odt_file_id, status: @print_job_spec.status, user_id: @print_job_spec.user_id } }
    end

    assert_redirected_to print_job_spec_url(PrintJobSpec.last)
  end

  test "should show print_job_spec" do
    get print_job_spec_url(@print_job_spec)
    assert_response :success
  end

  test "should get edit" do
    get edit_print_job_spec_url(@print_job_spec)
    assert_response :success
  end

  test "should update print_job_spec" do
    patch print_job_spec_url(@print_job_spec), params: { print_job_spec: { comment: @print_job_spec.comment, csv_file_id: @print_job_spec.csv_file_id, messages: @print_job_spec.messages, odt_file_id: @print_job_spec.odt_file_id, status: @print_job_spec.status, user_id: @print_job_spec.user_id } }
    assert_redirected_to print_job_spec_url(@print_job_spec)
  end

  test "should destroy print_job_spec" do
    assert_difference("PrintJobSpec.count", -1) do
      delete print_job_spec_url(@print_job_spec)
    end

    assert_redirected_to print_job_specs_url
  end
end
