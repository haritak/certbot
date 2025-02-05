require "application_system_test_case"

class SelfServicePrintJobSpecsTest < ApplicationSystemTestCase
  setup do
    @self_service_print_job_spec = self_service_print_job_specs(:one)
  end

  test "visiting the index" do
    visit self_service_print_job_specs_url
    assert_selector "h1", text: "Self service print job specs"
  end

  test "should create self service print job spec" do
    visit self_service_print_job_specs_url
    click_on "New self service print job spec"

    check "Active" if @self_service_print_job_spec.active
    fill_in "Field names", with: @self_service_print_job_spec.field_names
    fill_in "Print job spec", with: @self_service_print_job_spec.print_job_spec_id
    fill_in "Secret url part", with: @self_service_print_job_spec.secret_url_part
    check "Validate client email" if @self_service_print_job_spec.validate_client_email
    click_on "Create Self service print job spec"

    assert_text "Self service print job spec was successfully created"
    click_on "Back"
  end

  test "should update Self service print job spec" do
    visit self_service_print_job_spec_url(@self_service_print_job_spec)
    click_on "Edit this self service print job spec", match: :first

    check "Active" if @self_service_print_job_spec.active
    fill_in "Field names", with: @self_service_print_job_spec.field_names
    fill_in "Print job spec", with: @self_service_print_job_spec.print_job_spec_id
    fill_in "Secret url part", with: @self_service_print_job_spec.secret_url_part
    check "Validate client email" if @self_service_print_job_spec.validate_client_email
    click_on "Update Self service print job spec"

    assert_text "Self service print job spec was successfully updated"
    click_on "Back"
  end

  test "should destroy Self service print job spec" do
    visit self_service_print_job_spec_url(@self_service_print_job_spec)
    click_on "Destroy this self service print job spec", match: :first

    assert_text "Self service print job spec was successfully destroyed"
  end
end
