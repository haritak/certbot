require "application_system_test_case"

class EmailJobSpecsTest < ApplicationSystemTestCase
  setup do
    @email_job_spec = email_job_specs(:one)
  end

  test "visiting the index" do
    visit email_job_specs_url
    assert_selector "h1", text: "Email job specs"
  end

  test "should create email job spec" do
    visit email_job_specs_url
    click_on "New email job spec"

    fill_in "Attachment pattern", with: @email_job_spec.attachment_pattern
    fill_in "Csv entries", with: @email_job_spec.csv_entries
    fill_in "Print job spec", with: @email_job_spec.print_job_spec_id
    click_on "Create Email job spec"

    assert_text "Email job spec was successfully created"
    click_on "Back"
  end

  test "should update Email job spec" do
    visit email_job_spec_url(@email_job_spec)
    click_on "Edit this email job spec", match: :first

    fill_in "Attachment pattern", with: @email_job_spec.attachment_pattern
    fill_in "Csv entries", with: @email_job_spec.csv_entries
    fill_in "Print job spec", with: @email_job_spec.print_job_spec_id
    click_on "Update Email job spec"

    assert_text "Email job spec was successfully updated"
    click_on "Back"
  end

  test "should destroy Email job spec" do
    visit email_job_spec_url(@email_job_spec)
    click_on "Destroy this email job spec", match: :first

    assert_text "Email job spec was successfully destroyed"
  end
end
