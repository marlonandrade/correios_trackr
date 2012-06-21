#! /usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'nokogiri'
require 'open-uri'

class OptionsParser
  def self.parse(args)
    options = OpenStruct.new
    options.file = 'correios.txt'
    OptionParser.new do |opts|
      opts.banner = "Usage: correios.rb file"

      opts.separator ''
      opts.separator 'Specific options:'

      opts.on('-f', '--file [FILE]', 'File to parse') do |file|
        options.file = file
      end
    end.parse!
    options
  end
end

options = OptionsParser.parse(ARGV)

File.open(options.file).each_line do |line|
  store, product, track_code = line.split ';'
  puts "Getting tracking info for #{product}"
  puts "  Store: #{store}"

  correios_url = 'http://websro.correios.com.br/sro_bin/txect01$.QueryList?P_LINGUA=001&P_TIPO=001&P_COD_UNI='
  doc = Nokogiri::HTML(open(correios_url + track_code))

  track_info = []
  doc.xpath('//tr[2]/td').each do |info|
    track_info << info.content
  end

  if (track_info.size > 0)
    puts " Status: #{track_info[2]}#{track_info[2] =~ /ntrega/ ? ' <<<<<<<<<<<<<<<<<<<' : ''}"
    puts "   Date: #{track_info[0]}"
    puts "  Where: #{track_info[1]}"
  else
    puts '  [No tracking information found]'
  end

  puts ""
end
