require "test_helper"

class SelfServicePrintJobSpecsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @self_service_print_job_spec = self_service_print_job_specs(:one)
  end

  test "should get index" do
    get self_service_print_job_specs_url
    assert_response :success
  end

  test "should get new" do
    get new_self_service_print_job_spec_url
    assert_response :success
  end

  test "should create self_service_print_job_spec" do
    assert_difference("SelfServicePrintJobSpec.count") do
      post self_service_print_job_specs_url, params: { self_service_print_job_spec: { active: @self_service_print_job_spec.active, field_names: @self_service_print_job_spec.field_names, print_job_spec_id: @self_service_print_job_spec.print_job_spec_id, secret_url_part: @self_service_print_job_spec.secret_url_part, validate_client_email: @self_service_print_job_spec.validate_client_email } }
    end

    assert_redirected_to self_service_print_job_spec_url(SelfServicePrintJobSpec.last)
  end

  test "should show self_service_print_job_spec" do
    get self_service_print_job_spec_url(@self_service_print_job_spec)
    assert_response :success
  end

  test "should get edit" do
    get edit_self_service_print_job_spec_url(@self_service_print_job_spec)
    assert_response :success
  end

  test "should update self_service_print_job_spec" do
    patch self_service_print_job_spec_url(@self_service_print_job_spec), params: { self_service_print_job_spec: { active: @self_service_print_job_spec.active, field_names: @self_service_print_job_spec.field_names, print_job_spec_id: @self_service_print_job_spec.print_job_spec_id, secret_url_part: @self_service_print_job_spec.secret_url_part, validate_client_email: @self_service_print_job_spec.validate_client_email } }
    assert_redirected_to self_service_print_job_spec_url(@self_service_print_job_spec)
  end

  test "should destroy self_service_print_job_spec" do
    assert_difference("SelfServicePrintJobSpec.count", -1) do
      delete self_service_print_job_spec_url(@self_service_print_job_spec)
    end

    assert_redirected_to self_service_print_job_specs_url
  end
end
