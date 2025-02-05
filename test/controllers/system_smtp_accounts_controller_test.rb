require "test_helper"

class SystemSmtpAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @system_smtp_account = system_smtp_accounts(:one)
  end

  test "should get index" do
    get system_smtp_accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_system_smtp_account_url
    assert_response :success
  end

  test "should create system_smtp_account" do
    assert_difference("SystemSmtpAccount.count") do
      post system_smtp_accounts_url, params: { system_smtp_account: { description: @system_smtp_account.description, from: @system_smtp_account.from, password: @system_smtp_account.password, port: @system_smtp_account.port, server: @system_smtp_account.server, username: @system_smtp_account.username } }
    end

    assert_redirected_to system_smtp_account_url(SystemSmtpAccount.last)
  end

  test "should show system_smtp_account" do
    get system_smtp_account_url(@system_smtp_account)
    assert_response :success
  end

  test "should get edit" do
    get edit_system_smtp_account_url(@system_smtp_account)
    assert_response :success
  end

  test "should update system_smtp_account" do
    patch system_smtp_account_url(@system_smtp_account), params: { system_smtp_account: { description: @system_smtp_account.description, from: @system_smtp_account.from, password: @system_smtp_account.password, port: @system_smtp_account.port, server: @system_smtp_account.server, username: @system_smtp_account.username } }
    assert_redirected_to system_smtp_account_url(@system_smtp_account)
  end

  test "should destroy system_smtp_account" do
    assert_difference("SystemSmtpAccount.count", -1) do
      delete system_smtp_account_url(@system_smtp_account)
    end

    assert_redirected_to system_smtp_accounts_url
  end
end
