require "test_helper"

class OdtFilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get odt_files_index_url
    assert_response :success
  end

  test "should get show" do
    get odt_files_show_url
    assert_response :success
  end

  test "should get new" do
    get odt_files_new_url
    assert_response :success
  end

  test "should get create" do
    get odt_files_create_url
    assert_response :success
  end

  test "should get edit" do
    get odt_files_edit_url
    assert_response :success
  end

  test "should get update" do
    get odt_files_update_url
    assert_response :success
  end

  test "should get destroy" do
    get odt_files_destroy_url
    assert_response :success
  end

  test "should get download" do
    get odt_files_download_url
    assert_response :success
  end
end
