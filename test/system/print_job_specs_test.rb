require "application_system_test_case"

class PrintJobSpecsTest < ApplicationSystemTestCase
  setup do
    @print_job_spec = print_job_specs(:one)
  end

  test "visiting the index" do
    visit print_job_specs_url
    assert_selector "h1", text: "Print job specs"
  end

  test "should create print job spec" do
    visit print_job_specs_url
    click_on "New print job spec"

    fill_in "Comment", with: @print_job_spec.comment
    fill_in "Csv file", with: @print_job_spec.csv_file_id
    fill_in "Messages", with: @print_job_spec.messages
    fill_in "Odt file", with: @print_job_spec.odt_file_id
    fill_in "Status", with: @print_job_spec.status
    fill_in "User", with: @print_job_spec.user_id
    click_on "Create Print job spec"

    assert_text "Print job spec was successfully created"
    click_on "Back"
  end

  test "should update Print job spec" do
    visit print_job_spec_url(@print_job_spec)
    click_on "Edit this print job spec", match: :first

    fill_in "Comment", with: @print_job_spec.comment
    fill_in "Csv file", with: @print_job_spec.csv_file_id
    fill_in "Messages", with: @print_job_spec.messages
    fill_in "Odt file", with: @print_job_spec.odt_file_id
    fill_in "Status", with: @print_job_spec.status
    fill_in "User", with: @print_job_spec.user_id
    click_on "Update Print job spec"

    assert_text "Print job spec was successfully updated"
    click_on "Back"
  end

  test "should destroy Print job spec" do
    visit print_job_spec_url(@print_job_spec)
    click_on "Destroy this print job spec", match: :first

    assert_text "Print job spec was successfully destroyed"
  end
end
