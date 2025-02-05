class SystemSmtpAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_system_smtp_account, 
    only: %i[ show edit update destroy test_system_smtp_account ]

  # GET /system_smtp_accounts or /system_smtp_accounts.json
  def index
    @system_smtp_accounts = current_user.system_smtp_accounts
  end

  # GET /system_smtp_accounts/1 or /system_smtp_accounts/1.json
  def show
  end

  # GET /system_smtp_accounts/new
  def new
    @system_smtp_account = SystemSmtpAccount.new
  end

  # GET /system_smtp_accounts/1/edit
  def edit
  end

  # POST /system_smtp_accounts or /system_smtp_accounts.json
  def create
    @system_smtp_account = SystemSmtpAccount.new(system_smtp_account_params)
    @system_smtp_account.user = current_user

    respond_to do |format|
      if @system_smtp_account.save
        format.html { redirect_to system_smtp_account_url(@system_smtp_account), notice: "System smtp account was successfully created." }
        format.json { render :show, status: :created, location: @system_smtp_account }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @system_smtp_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /system_smtp_accounts/1 or /system_smtp_accounts/1.json
  def update
    respond_to do |format|
      if @system_smtp_account.update(system_smtp_account_params)
        format.html { redirect_to system_smtp_account_url(@system_smtp_account), notice: "System smtp account was successfully updated." }
        format.json { render :show, status: :ok, location: @system_smtp_account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @system_smtp_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /system_smtp_accounts/1 or /system_smtp_accounts/1.json
  def destroy
    @system_smtp_account.destroy

    respond_to do |format|
      format.html { redirect_to system_smtp_accounts_url, notice: "System smtp account was successfully destroyed." }
    end
  end

  def test_system_smtp_account

    begin
      UserMailer.with(user_id: current_user.id,
                      smtp_account_id: @system_smtp_account.id,
                      smtp_password_pin: nil).
                      test_smtp_server_email.deliver
    rescue => e
      redirect_to @system_smtp_account,
        alert: "Η αποστολή του δοκιμαστικού email απέτυχε. (" +
        e.message + ")" 
      return
    end

    redirect_to @system_smtp_account, notice: 'Email was sent successfully.' 
    return
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_system_smtp_account
      begin
        @system_smtp_account = SystemSmtpAccount.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path, alert: "Δεν βρέθηκε"
        return
      end

      if @system_smtp_account.user != current_user and !current_user.is_admin?
        redirect_to root_path, alert: "Ο λογαριασμός ανήκει σε άλλον χρήστη."
        return
      end
    end

    # Only allow a list of trusted parameters through.
    def system_smtp_account_params
      params.require(:system_smtp_account).permit(:description, :from, :server, :port, :username, :password)
    end
end
