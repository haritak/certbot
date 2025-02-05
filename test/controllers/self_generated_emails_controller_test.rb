require "test_helper"

class SelfGeneratedEmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get self_generated_emails_index_url
    assert_response :success
  end
end
