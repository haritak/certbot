require "test_helper"

class GeneratedFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @generated_file = generated_files(:one)
  end

  test "should get index" do
    get generated_files_url
    assert_response :success
  end

  test "should get new" do
    get new_generated_file_url
    assert_response :success
  end

  test "should create generated_file" do
    assert_difference("GeneratedFile.count") do
      post generated_files_url, params: { generated_file: { path: @generated_file.path, print_job_spec_id: @generated_file.print_job_spec_id } }
    end

    assert_redirected_to generated_file_url(GeneratedFile.last)
  end

  test "should show generated_file" do
    get generated_file_url(@generated_file)
    assert_response :success
  end

  test "should get edit" do
    get edit_generated_file_url(@generated_file)
    assert_response :success
  end

  test "should update generated_file" do
    patch generated_file_url(@generated_file), params: { generated_file: { path: @generated_file.path, print_job_spec_id: @generated_file.print_job_spec_id } }
    assert_redirected_to generated_file_url(@generated_file)
  end

  test "should destroy generated_file" do
    assert_difference("GeneratedFile.count", -1) do
      delete generated_file_url(@generated_file)
    end

    assert_redirected_to generated_files_url
  end
end
