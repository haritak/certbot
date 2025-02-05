require "application_system_test_case"

class PrintJobsTest < ApplicationSystemTestCase
  setup do
    @print_job = print_jobs(:one)
  end

  test "visiting the index" do
    visit print_jobs_url
    assert_selector "h1", text: "Print jobs"
  end

  test "should create print job" do
    visit print_jobs_url
    click_on "New print job"

    fill_in "Print job spec", with: @print_job.print_job_spec_id
    click_on "Create Print job"

    assert_text "Print job was successfully created"
    click_on "Back"
  end

  test "should update Print job" do
    visit print_job_url(@print_job)
    click_on "Edit this print job", match: :first

    fill_in "Print job spec", with: @print_job.print_job_spec_id
    click_on "Update Print job"

    assert_text "Print job was successfully updated"
    click_on "Back"
  end

  test "should destroy Print job" do
    visit print_job_url(@print_job)
    click_on "Destroy this print job", match: :first

    assert_text "Print job was successfully destroyed"
  end
end
