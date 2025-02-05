require "application_system_test_case"

class GeneratedFilesTest < ApplicationSystemTestCase
  setup do
    @generated_file = generated_files(:one)
  end

  test "visiting the index" do
    visit generated_files_url
    assert_selector "h1", text: "Generated files"
  end

  test "should create generated file" do
    visit generated_files_url
    click_on "New generated file"

    fill_in "Path", with: @generated_file.path
    fill_in "Print job spec", with: @generated_file.print_job_spec_id
    click_on "Create Generated file"

    assert_text "Generated file was successfully created"
    click_on "Back"
  end

  test "should update Generated file" do
    visit generated_file_url(@generated_file)
    click_on "Edit this generated file", match: :first

    fill_in "Path", with: @generated_file.path
    fill_in "Print job spec", with: @generated_file.print_job_spec_id
    click_on "Update Generated file"

    assert_text "Generated file was successfully updated"
    click_on "Back"
  end

  test "should destroy Generated file" do
    visit generated_file_url(@generated_file)
    click_on "Destroy this generated file", match: :first

    assert_text "Generated file was successfully destroyed"
  end
end
