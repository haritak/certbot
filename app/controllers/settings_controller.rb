class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[ show edit update ]

  def index
    if current_user.is_admin?
      @users = User.all
    else
      @users = current_user
    end
  end

  def show
  end

  def edit
  end

  def update
    @user.smtp_account = nil
    if settings_params[ :smtp_account_id ] and settings_params[ :smtp_account_id ] != ""
      smtp_account = SmtpAccount.find( settings_params[ :smtp_account_id ] )
      @user.smtp_account = smtp_account
    end
    if current_user.is_admin?
      @user.activated = settings_params[ :activated ]
    end

    respond_to do |format|
      if @user.save
        if @user == current_user
          format.html { redirect_to settings_path, 
                        notice: "Η επιλογή λογαριασμού έγινε επιτυχώς" }
        else
          format.html { redirect_to users_path, 
                        notice: "SMTP Account of #{@user.email} selected." }
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def set_session_password_pin
    session[ :smtp_password_pin ] = params[ :smtp_password_pin ]
    redirect_to root_path
  end

  # https://gist.github.com/yukithm/de7fcba1bea8a997554353e556031b51
  CIPHER_ALGO = "AES-256-CBC"
  SALT_SIZE = 8

  def self.encrypt(data, pass)
    data = "CHECK" + data
    salt = OpenSSL::Random.random_bytes(SALT_SIZE)
    cipher = OpenSSL::Cipher::Cipher.new(CIPHER_ALGO)
    cipher.encrypt
    cipher.pkcs5_keyivgen(pass, salt, 1)
    enc_data = cipher.update(data) + cipher.final
    salt + enc_data
  end

  def self.decrypt(enc_data, pass)
    enc_data = enc_data.dup
    enc_data.force_encoding("ASCII-8BIT")
    salt = enc_data[0, SALT_SIZE]
    data = enc_data[SALT_SIZE..-1]
    cipher = OpenSSL::Cipher::Cipher.new(CIPHER_ALGO)
    cipher.decrypt
    cipher.pkcs5_keyivgen(pass, salt, 1)
    return_value = cipher.update(data) + cipher.final
    return return_value[5..] if return_value.start_with? "CHECK"
    thrown Exception.new "Data encryption/decryption error."
  end


  private

  def set_user
    if current_user.is_admin?
      @user = User.find( params[ :id ] )
    else
      @user = current_user
    end
  end

  # Only allow a list of trusted parameters through.
  def settings_params
    params.require(:user).permit(
      :smtp_account_id,
      :activated
    )
  end


end
