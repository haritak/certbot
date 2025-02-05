class SmtpAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_smtp_account, 
    only: %i[ show edit update destroy test_smtp_account]

  def index
    @smtp_accounts = current_user.smtp_accounts - current_user.system_smtp_accounts
  end

  def new
    @smtp_account = SmtpAccount.new
    @smtp_account.user = current_user
  end

  def create
    @smtp_account = SmtpAccount.new
    @smtp_account.user = current_user
    save_my_account do |success|
      if not success
        render :new, 
          status: :unprocessable_entity,
          locals: { smtp_account: @smtp_account }
      else
        respond_to do |format|
          format.html { redirect_to smtp_accounts_path( @smtp_account.user ), 
                      notice: "Smtp account successfully created." }
        end
      end
    end 
  end

  def update
    save_my_account do |success|
      if not success
        render :edit, 
          status: :unprocessable_entity,
          locals: { smtp_account: @smtp_account }
      else
        respond_to do |format|
          format.html { redirect_to smtp_account_path( @smtp_account.user ), 
                      notice: "Smtp account successfully updated." }
        end
      end
    end 
  end

  def destroy
    @smtp_account.destroy

    respond_to do |format|
      format.html { redirect_to smtp_accounts_path, 
                    notice: "smtp account was successfully destroyed." }
    end
  end

  def save_my_account
    password_pin = smtp_params[ :password_pin ]&.strip
    if password_pin != "" 
      if !smtp_params[ :username ] or !smtp_params[ :password ] or
          smtp_params[ :username ].strip == "" or smtp_params[ :password ].strip == ""
        @smtp_account.errors.add(:base, "Το username και το password " +
                                 "πρέπει να δίδονται ταυτόχρονα ώστε " +
                                 "να κρυπτογραφούνται με το ίδιο pin")
        yield false
        return
      else
        encrypted_username = 
          SettingsController.encrypt( smtp_params[ :username ].strip, password_pin ) 
        encryped_password =
          SettingsController.encrypt( smtp_params[ :password ].strip, password_pin ) 
      end
    else
      if smtp_params[ :username ] != "" or smtp_params[ :password ] != ""
        @smtp_account.errors.add(:base, "Το password pin απαιτείται " +
                         "για την ενημέρωση username και το password.")
        yield false
        return
      end
    end

    @smtp_account.description = smtp_params[ :description ].strip
    @smtp_account.server = smtp_params[ :server ].strip
    @smtp_account.port = smtp_params[ :port ].strip
    @smtp_account.from = smtp_params[ :from ].strip

    if password_pin != ""
      @smtp_account.username = Base64.strict_encode64( encrypted_username )
      @smtp_account.password = Base64.strict_encode64( encryped_password )
    end
    if @smtp_account.save
      yield true
    else
      yield false
    end
  end

  def test_smtp_account
    password_pin = params[ :smtp_password_pin ]
    if not password_pin or password_pin == ""
      password_pin = session[ :smtp_password_pin ]
    else
      session[ :smtp_password_pin ] = password_pin
    end
    if password_pin == "" 
      redirect_to @smtp_account,
        alert: "Το pin είναι απαραίτητο " +
        "για την αποκρυπτογράφηση username και password"
      return
    end
   
    # Just try to decode username.
    # Error indicates possibly wrong password_pin
    #
    begin
      decoded_username = Base64.strict_decode64( @smtp_account.username )
      SettingsController.decrypt( decoded_username, password_pin )
    rescue => e
      redirect_to @smtp_account,
        alert: "Η αποκρυπτογράφηση username/password απέτυχε (λάθος pin ;)"
      return
    end

    begin
      UserMailer.with(user_id: current_user.id,
                      smtp_account_id: @smtp_account.id,
                      smtp_password_pin: password_pin).
                      test_smtp_server_email.deliver
    rescue => e
      redirect_to @smtp_account,
        alert: "Η αποστολή του δοκιμαστικού email απέτυχε. (" +
        e.message + ")" 
      return
    end

    redirect_to @smtp_account, notice: 'Email was sent successfully.' 
    return
  end


  private

  def set_smtp_account 
    begin
      @smtp_account = SmtpAccount.find( params[:id] )
    rescue ActiveRecord::RecordNotFound => e
      redirect_to root_path, alert: "Δεν βρέθηκε"
      return
    end

    if @smtp_account.user != current_user and !current_user.is_admin?
      redirect_to root_path, alert: "Ο λογαριασμός ανήκει σε άλλον χρήστη."
      return
    end

  end

  def smtp_params
    params.require(:smtp_account).
      permit(
             :id,
             :description,
             :from,
             :server, 
             :port, 
             :username, 
             :password, 
             :password_pin,
            )
  end
end
