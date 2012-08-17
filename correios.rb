#! /usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'nokogiri'
require 'open-uri'
require 'colorize'

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
  url = "http://websro.correios.com.br/sro_bin/txect01$.QueryList?P_LINGUA=001&P_COD_UNI=#{track_code}"

  puts "Getting tracking info for #{product}".blue
  puts "  Store: #{store}"
  puts "    URL: #{url}"

  doc = Nokogiri::HTML(open(url))

  track_info = []
  rowspan = nil
  doc.xpath('//tr[2]/td').each do |info|
    track_info << info.content
    rowspan = info.attributes.select { |attr| attr == 'rowspan' }
  end

  if (track_info.size > 0)
    status_color = track_info[2] =~ /ntrega/ ? :green : :uncolorize
    puts " Status: #{track_info[2]}".colorize(status_color)
    puts "   Date: #{track_info[0]}"
    puts "  Where: #{track_info[1]}"
    if rowspan
      puts "         #{doc.xpath('//tr[3]/td').map { |info| info.content }.join}"
    end
  else
    puts '  [No tracking information found]'.red
  end


  puts ""
end
