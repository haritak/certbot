#!/usr/bin/env -S /home/haritak/Coding/certificate_generator/certPrintShop/bin/rails runner
class MergeConvertOdt

  def initialize(work_dir:, odt_file:, csv_file:)
    @work_dir = work_dir
    @odt_file = odt_file
    @csv_file = csv_file

    @log = Rails.logger
    @current_state = PrintJobSpec::STATUS[ :generating_odts ]

    msg = "Warning: Files inside /tmp get cleaned at reboot. Reboots can happen without warning."
    @log.warn( msg ) if @work_dir.start_with? "/tmp"


    Dir.mkdir( @work_dir ) if not File.exist? @work_dir #will boom if failed
    Dir.chdir( @work_dir )
  end

  def generate_all_odts

    if @current_state != PrintJobSpec::STATUS[ :generating_odts ]
      @log.error "Error: not in GENERATE_ODT state!"
      return
    end

    total_csv_lines = CSV.read( @csv_file ).length

    @log.info " --- Generating ODTs --- "
    @log.info "Template file is #{@odt_file}"
    @log.info "CSV file is #{@csv_file} with #{total_csv_lines} lines"

    produced_errors = []
    produced_filenames = []
    csv_row_index = 0 #so that it starts from ONE (1 should be the first email of csv and the generated file should be 1_email.odt)
    CSV.foreach( @csv_file, headers: true, encoding: "utf-8", quote_char: '"') do |row|
      csv_row_index += 1
      next if !row
      next if !row[0] #empty lines return nil
      next if !row[-1] #empty lines return nil
      next if !email_of( row )
      begin
        @log.info "> Working on csv row number #{csv_row_index}"
        gender = "unknown"
        if row["GENDER"]
          case row["GENDER"].strip.downcase
          when "ο" then gender = "male"
          when "o" then gender = "male"
          when "η" then gender = "female"
          when "h" then gender = "female"
          else gender = "unknown"
          end
        end

        Dir.chdir( @work_dir )
        # work_dir name is based upon USERNAME and PRINT JOB SPEC ID
        # therefore it is unique for each print_job_spec.
        #
        # Inside this directory,
        # each file start with the corresponding csv_row (which starts
        # from 1) and follow an _ and then the email of the recipient.
        #
        # Filename needs to be a plain filename (not inside a directory)
        trgFilename = "#{csv_row_index}_#{email_of( row ).strip}.odt" 

        if File.exist? trgFilename
          @log.info ">> File #{trgFilename} already exists, skipping."
        else
          generatedOdt = ODFReport::Report.new( @odt_file ) do |r|
            if gender == "female"
              r.add_field :o, "η"
              r.add_field :ton, "την"
              r.add_field :ston, "στην"
              r.add_field :toy, "της"
              r.add_field :student, "μαθήτρια"
              r.add_field :student_gen, "μαθήτριας"
              r.add_field :student_acc, "μαθήτρια"
            else
              r.add_field :o, "ο" 
              r.add_field :ton, "τον" 
              r.add_field :ston, "στον" 
              r.add_field :toy, "του" 
              r.add_field :student, "μαθητής"
              r.add_field :student_gen, "μαθητή"
              r.add_field :student_acc, "μαθητή"
            end
            row.headers.each do |header|
              header_symbol = header&.strip.downcase.to_sym
              r.add_field header_symbol, row[ header ]&.strip
            end
          end
          generatedOdt.generate trgFilename
          @log.info ">> Generated #{trgFilename}."
        end
      rescue => e
        produced_errors << e.message
        produced_filenames << trgFilename
        @log.error "Failed to generate #{trgFilename} with error #{e.message}."
        next
      end
      produced_errors << ""
      produced_filenames << trgFilename
    end

    @current_state = "ODTs_GENERATED"

    return { errors: produced_errors, 
             filenames: produced_filenames }
  end

  def generate_missing_pdfs
    @current_state = "GENERATE_PDFs"
    @log.info " --- Generating PDFs --- "

    Dir.chdir( @work_dir )
    
    filenames = Dir.glob "*@*odt"
    produced_filenames = []

    odtsWithMissingPdfs = []
    filenames.each do |fn|
      pdf_file = "#{File.basename( fn, ".odt")}.pdf"
      if not File.exist? pdf_file
        odtsWithMissingPdfs << fn
      else
        @log.info "File #{pdf_file} allready exists. Skipping conversion."
      end
    end

    if odtsWithMissingPdfs.length == 0
      @log.info "All requested files have been converted to pdf."
    else
      # start unoconv
      # unoconv requires libreoffice-writer, which is not installed
      # by default when installing unoconv
      #cmd_output = `unoconv #{odtsWithMissingPdfs.join(" ")}`
      cmd_output = `libreoffice --convert-to pdf #{odtsWithMissingPdfs.join(" ")}`
      
      if not $?.success?
        throw Exception.new "Failed to execute pdf conversion: #{cmd_output}"
      end
    end

    Dir.glob("*pdf").each do |pdf_fn|
        produced_filenames << pdf_fn
    end

    @current_state = "SIGNING_PDFs"
    @log.info " --- Signing PDFs --- "

    `java -version`
    if not $?.success?
      @log.error "Missing java to sign pdfs!"
      return produced_filenames
    end

    sign_prg = Rails.root.join "bin/open-pdf-sign.jar"
    if not File.exist? sign_prg
      @log.error "Missing open-pdf-sign.jar to sign pdfs!"
      return produced_filenames
    end

    sign_cmd = "java -jar #{sign_prg}"
    `#{sign_cmd} --version`
    if not $?.success?
      @log.error "Failed to execute #{sign_cmd}"
      return produced_filenames
    end

    priv_key = Rails.root.join ("config/keys/pdf_signing/priv.key")
    certificate = Rails.root.join("config/keys/pdf_signing/cert.pem")

    if not File.exist? priv_key
      @log.error "Missing private key to sign pdfs!"
      return produced_filenames
    end

    if not File.exist? certificate
      @log.error "Missing certificate to sign pdfs!"
      return produced_filenames
    end

    Dir.mkdir "signed_pdfs" unless File.exist? "signed_pdfs"
    Dir.mkdir "unsigned_pdfs" unless File.exist? "unsigned_pdfs"

    signing_cmd = "#{sign_cmd} -k #{priv_key} -c #{certificate} -p\"#{Rails.env["PDF_SIGNING_PASS"]}\""

    produced_filenames.each do |pdf_file|
      cmd_line = "#{signing_cmd} -i #{pdf_file} -o signed_pdfs/#{pdf_file}"
      @log.info cmd_line
      `#{cmd_line}`
      if $?.success?
        File.mv pdf_file, "unsigned_pdfs/#{pdf_file}"
        FileUtils.ln_s "signed_pdfs/#{pdf_file}", pdf_file
      end
    end


    return produced_filenames
  end

  private

  def email_of( csv_row )
    # Example of csv_row :
    #
    # <CSV::Row "STON":"στον" " ONOMA":" Αστερίξ" " EPWNYMO":" Γαλάτη" " TOY":" του" " PATRWNYMO":" Νταμαλίξ" │-rwxr-xr-x  1 haritaksch haritaksch   91 Ιαν  18 08:57 start_mailhog.sh*
    # " TITLOS":" Μέγας Γαλάτης" " email":" haritak@sch.gr">
    #
    # p r[0] --> "στον"
    # p r.headers[-1] --> " email" 
    

    # according to specs, email should be the last element of the row.
    csv_row[ -1 ].strip.html_safe #email has already been checked during csv validation
  end
end



