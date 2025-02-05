require "application_system_test_case"

class SelfServiceGeneratedFilesTest < ApplicationSystemTestCase
  setup do
    @self_service_generated_file = self_service_generated_files(:one)
  end

  test "visiting the index" do
    visit self_service_generated_files_url
    assert_selector "h1", text: "Self service generated files"
  end

  test "should create self service generated file" do
    visit self_service_generated_files_url
    click_on "New self service generated file"

    fill_in "Path", with: @self_service_generated_file.path
    fill_in "Self service print job", with: @self_service_generated_file.self_service_print_job_id
    click_on "Create Self service generated file"

    assert_text "Self service generated file was successfully created"
    click_on "Back"
  end

  test "should update Self service generated file" do
    visit self_service_generated_file_url(@self_service_generated_file)
    click_on "Edit this self service generated file", match: :first

    fill_in "Path", with: @self_service_generated_file.path
    fill_in "Self service print job", with: @self_service_generated_file.self_service_print_job_id
    click_on "Update Self service generated file"

    assert_text "Self service generated file was successfully updated"
    click_on "Back"
  end

  test "should destroy Self service generated file" do
    visit self_service_generated_file_url(@self_service_generated_file)
    click_on "Destroy this self service generated file", match: :first

    assert_text "Self service generated file was successfully destroyed"
  end
end
