require "test_helper"

class SelfServiceGeneratedFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @self_service_generated_file = self_service_generated_files(:one)
  end

  test "should get index" do
    get self_service_generated_files_url
    assert_response :success
  end

  test "should get new" do
    get new_self_service_generated_file_url
    assert_response :success
  end

  test "should create self_service_generated_file" do
    assert_difference("SelfServiceGeneratedFile.count") do
      post self_service_generated_files_url, params: { self_service_generated_file: { path: @self_service_generated_file.path, self_service_print_job_id: @self_service_generated_file.self_service_print_job_id } }
    end

    assert_redirected_to self_service_generated_file_url(SelfServiceGeneratedFile.last)
  end

  test "should show self_service_generated_file" do
    get self_service_generated_file_url(@self_service_generated_file)
    assert_response :success
  end

  test "should get edit" do
    get edit_self_service_generated_file_url(@self_service_generated_file)
    assert_response :success
  end

  test "should update self_service_generated_file" do
    patch self_service_generated_file_url(@self_service_generated_file), params: { self_service_generated_file: { path: @self_service_generated_file.path, self_service_print_job_id: @self_service_generated_file.self_service_print_job_id } }
    assert_redirected_to self_service_generated_file_url(@self_service_generated_file)
  end

  test "should destroy self_service_generated_file" do
    assert_difference("SelfServiceGeneratedFile.count", -1) do
      delete self_service_generated_file_url(@self_service_generated_file)
    end

    assert_redirected_to self_service_generated_files_url
  end
end
