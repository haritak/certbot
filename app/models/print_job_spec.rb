# == Schema Information
#
# Table name: print_job_specs
#
#  id          :bigint           not null, primary key
#  comment     :text(65535)
#  messages    :text(65535)
#  status      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  csv_file_id :bigint           not null
#  odt_file_id :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_print_job_specs_on_csv_file_id  (csv_file_id)
#  index_print_job_specs_on_odt_file_id  (odt_file_id)
#  index_print_job_specs_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (csv_file_id => csv_files.id)
#  fk_rails_...  (odt_file_id => odt_files.id)
#  fk_rails_...  (user_id => users.id)
#
class CsvOdtFileValidator < ActiveModel::Validator
  def validate( record )

    # CSV made optional
    #presence of csv file
    #if !record.csv_file or
        #!record.csv_file.csvfile or 
        #!record.csv_file.csvfile.attached?
      #record.errors.add :base, "Missing csv file."
      #return
    #end

    #presence of odt file
    if !record.odt_file or
        !record.odt_file.odtfile or 
        !record.odt_file.odtfile.attached?
      record.errors.add :base, "Missing odt file."
      return
    end

    if record.csv_file
      # just a shortcut
      csvFile = record.csv_file.csvfile

      #validate data of csv file
      data = csvFile.download
      csvdata = nil
      begin
        csvdata = CSV.parse( data, headers: true, encoding: "utf-8", quote_char: '"')
      rescue => e
        puts e.class
        puts e.message
        record.errors.add :base, "CSV file corrupt"
        record.errors.add :base, e.message
        return
      end

      #check presence of headers
      csvHeaders = csvdata.headers
      if !csvHeaders 
        record.errors.add :base, "Error while parsing headers of CSV file."
        return
      end
      if csvHeaders.length == 0
        record.errors.add :base, "Error while parsing headers of CSV file - empty CSV header."
        return
      end

      #check presence of email
      if !csvHeaders.find { |header| header =~ /email/i }
        record.errors.add :base, "Missing email column: " +
          "CSV file should include a column named email, " +
          "containing the email of the final recipient " +
          "for the printed card."
      end

      #email should be positioned last
      if !(csvHeaders[-1] =~ /email/i)
        record.errors.add :base, "email column should be the last one."
      end

      #check for capital letters
      csvHeaders.each do |header|
        next if header =~ /email/
        if not (header.strip =~ /\A[A-Z_]+\z/)
          record.errors.add :base, "Header '#{header}' contains " +
            "invalid letters. Allowed letters are A...Z " +
            "(capital only). No other letters/symbols accepted."
        end
      end

      csvdata.each_with_index do |csv_line, line_no|
        next if csv_line.empty?  #ignore empty lines
        next if csv_line.to_h.values.join() == ""  #previous misses some.
        #check email 
        email = csv_line[-1]&.strip
        if email !~ URI::MailTo::EMAIL_REGEXP
          record.errors.add :base, "Invalid email for " +
            "line #{line_no} : #{email}"
        end

        #check length of every value
        csv_line.each do |data|
          if data.length > 100
            record.errors.add :base, "Field value too long at " +
              "line #{line_no} for field #{data[0]}: '#{data[1]}'"
          end
        end
      end



      #
      # Δεν βρήκα τρόπο να τσεκάρω ότι :
      # όλα τα headers εμφανίζονται στο odt
      # μόνο αυτά εμφανίζονται και όχι άλλα.
      #
      # Ο λόγος είναι ότι η βιβλιοθήκη ODFReport δεν 
      # δίνει κάποιο API ως προς τα identifiers που υπάρχουν
      # μέσα στο odt ...
      #
      # Οπότε απλά δοκιμάζουμε αν γίνεται μετατροπή...
      #

      # another shortcut
      odtFile = record.odt_file.odtfile

      generatedOdt = nil
      not_found_headers = []
      not_used_place_holders = []

      #active storage trick:
      begin
        odtFile.open do |file|
          zipFile = Zip::File.open file.path
          not_used_place_holders += zipFile.read( 'content.xml' ).scan( /\[[A-Z_]+?\]/ )
          generatedOdt = ODFReport::Report.new(file.path) do |r|
            csvHeaders.each do |header|
              if header !~ /email/i
                header_found_in_odt = not_used_place_holders.grep "[#{header.strip}]"
                not_found_headers << header if header_found_in_odt.length == 0
                not_used_place_holders -= header_found_in_odt
              end

  
              header_symbol = header.strip.downcase.to_sym
              r.add_field header_symbol, 'validation test'
            end
          end
          generatedOdt.generate #has to be inside odtFile.open!
          #otherwise the tmp file is lost
        end

      rescue => e
        record.errors.add :base, "Failed processing of odt file: " +
          e.message
      end

      if not_found_headers.length > 1
        record.errors.add :base, "Headers #{not_found_headers.join ', '} were not found inside odt."
      end

      #remove autogenerated place holders
      not_used_place_holders -= ["[O]", "[TON]", "[STON]", "[TOY]", "[STUDENT]", "[STUDENT_GEN]", "[STUDENT_ACC]"] 
      if not_used_place_holders.length != 0
        record.errors.add :base, "ODT contains the fields #{not_used_place_holders.join ', '} which were not detected inside csv."
      end

    end #if csv exists...

  end
end

class PrintJobSpec < ApplicationRecord

  STATUS = {
    idle: "IDLE",
    preparing: "PREPARING",
    generating_odts: "GENERATING ODTs",
    generating_odts_completed: "ODTs GENERATED",
    waiting_pdfs: "WAITING TO GENERATE PDFs",
    generating_pdfs: "GENERATING PDFs",
    finished: "FINISHED",

    backup: "CREATING BACKUP",

    internal_error: "ERROR",
  }

  belongs_to :user
  belongs_to :odt_file
  belongs_to :csv_file, optional: true

  has_many :print_jobs
  has_many :generated_files #belong directly to print_job_spec
  has_many :self_service_print_job_specs
  has_many :self_service_print_jobs, 
    through: :self_service_print_job_specs
  has_many :self_service_generated_files, 
    through: :self_service_print_jobs
  has_one :email_job_spec


  validates_with CsvOdtFileValidator

  def description
    "#{user.email}: #{id} #{comment} #{odt_file.filename} #{csv_file&.filename}"
  end

  def to_s
    "[Εργασία #{id}]"
  end

  def get_csv_headers
    csv_contents = csv_file&.csvfile&.download
    return nil if !csv_contents
    csv = CSV.parse( csv_contents, headers: true, encoding: "utf-8" )

    csv.headers
  end

  def get_selected_csv_entries_with_lineno( selected_csv_entries = nil )

    to_return = []

    csv_contents = csv_file&.csvfile&.download
    return nil if !csv_contents

    csv = CSV.parse( csv_contents, headers: true, encoding: "utf-8" )
    csv.each_with_index do |csv_line, line_no|
      line_no += 1
      if selected_csv_entries[0] == "all" or  selected_csv_entries.include? "#{line_no}"
        to_return << [line_no, csv_line]
      end 
    end

    to_return
  end

  #def email_job_spec?
    #EmailJobSpec.where( print_job_spec: self ).count > 0
  #end

end
