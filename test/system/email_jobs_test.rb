require "application_system_test_case"

class EmailJobsTest < ApplicationSystemTestCase
  setup do
    @email_job = email_jobs(:one)
  end

  test "visiting the index" do
    visit email_jobs_url
    assert_selector "h1", text: "Email jobs"
  end

  test "should create email job" do
    visit email_jobs_url
    click_on "New email job"

    fill_in "Csv entry", with: @email_job.csv_entry
    fill_in "Email job spec", with: @email_job.email_job_spec_id
    fill_in "Execution job", with: @email_job.execution_job_id
    fill_in "Retries left", with: @email_job.retries_left
    fill_in "Status", with: @email_job.status
    click_on "Create Email job"

    assert_text "Email job was successfully created"
    click_on "Back"
  end

  test "should update Email job" do
    visit email_job_url(@email_job)
    click_on "Edit this email job", match: :first

    fill_in "Csv entry", with: @email_job.csv_entry
    fill_in "Email job spec", with: @email_job.email_job_spec_id
    fill_in "Execution job", with: @email_job.execution_job_id
    fill_in "Retries left", with: @email_job.retries_left
    fill_in "Status", with: @email_job.status
    click_on "Update Email job"

    assert_text "Email job was successfully updated"
    click_on "Back"
  end

  test "should destroy Email job" do
    visit email_job_url(@email_job)
    click_on "Destroy this email job", match: :first

    assert_text "Email job was successfully destroyed"
  end
end
