#!/usr/bin/env ruby
require 'csv'

DATABASE_FILE = "urls.csv"
TARGET_FOLDER = "./generated_qrcodes"

csvdata = CSV.parse( File.read( DATABASE_FILE ), headers:true, encoding: "utf-8",  quote_char: '"')

csvdata.each do |dataline|
  url = dataline[ "URL" ]
  title = dataline[ "TITLE" ]

  `echo #{url} | qr > #{TARGET_FOLDER}/'#{title}.png'`
  if not $?.success?
    throw Exception.new "#{title}"
  end
end
