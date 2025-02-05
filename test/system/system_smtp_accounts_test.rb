require "application_system_test_case"

class SystemSmtpAccountsTest < ApplicationSystemTestCase
  setup do
    @system_smtp_account = system_smtp_accounts(:one)
  end

  test "visiting the index" do
    visit system_smtp_accounts_url
    assert_selector "h1", text: "System smtp accounts"
  end

  test "should create system smtp account" do
    visit system_smtp_accounts_url
    click_on "New system smtp account"

    fill_in "Description", with: @system_smtp_account.description
    fill_in "From", with: @system_smtp_account.from
    fill_in "Password", with: @system_smtp_account.password
    fill_in "Port", with: @system_smtp_account.port
    fill_in "Server", with: @system_smtp_account.server
    fill_in "Username", with: @system_smtp_account.username
    click_on "Create System smtp account"

    assert_text "System smtp account was successfully created"
    click_on "Back"
  end

  test "should update System smtp account" do
    visit system_smtp_account_url(@system_smtp_account)
    click_on "Edit this system smtp account", match: :first

    fill_in "Description", with: @system_smtp_account.description
    fill_in "From", with: @system_smtp_account.from
    fill_in "Password", with: @system_smtp_account.password
    fill_in "Port", with: @system_smtp_account.port
    fill_in "Server", with: @system_smtp_account.server
    fill_in "Username", with: @system_smtp_account.username
    click_on "Update System smtp account"

    assert_text "System smtp account was successfully updated"
    click_on "Back"
  end

  test "should destroy System smtp account" do
    visit system_smtp_account_url(@system_smtp_account)
    click_on "Destroy this system smtp account", match: :first

    assert_text "System smtp account was successfully destroyed"
  end
end
