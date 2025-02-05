require "test_helper"

class CsvFilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get csv_files_index_url
    assert_response :success
  end

  test "should get show" do
    get csv_files_show_url
    assert_response :success
  end

  test "should get new" do
    get csv_files_new_url
    assert_response :success
  end

  test "should get create" do
    get csv_files_create_url
    assert_response :success
  end

  test "should get edit" do
    get csv_files_edit_url
    assert_response :success
  end

  test "should get update" do
    get csv_files_update_url
    assert_response :success
  end

  test "should get destroy" do
    get csv_files_destroy_url
    assert_response :success
  end

  test "should get download" do
    get csv_files_download_url
    assert_response :success
  end
end
