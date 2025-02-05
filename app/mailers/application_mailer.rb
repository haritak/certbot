class ApplicationMailer < ActionMailer::Base
  #rescue_from( Net::ReadTimeout ) do |e|
    #@log = Rails.logger
    #@log.error "Ignoring Net::ReadTimeout error : #{e}, #{e.message}"
  #end

  #rescue_from( Net::WriteTimeout ) do |e|
    #@log = Rails.logger
    #@log.error "Ignoring Net::WriteTimeout error : #{e}, #{e.message}"
  #end

  #default from: "from@example.com"
  #default "Message-ID" => lambda {"<#{SecureRandom.uuid}@server42.pdekritis.gr"}
  layout "mailer"

end
