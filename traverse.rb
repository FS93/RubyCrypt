# frozen_string_literal: true
require 'find'
require_relative './parse_file.rb'
require 'ruby-progressbar'

progressbar = ProgressBar.create(:total => 111244, :throttle_rate => 5)

directory_path = '/Daten/Code/gitlab/'

output = File.new('output', 'w+')
errors = File.new('errors', 'w+')

Find.find(directory_path) do |path|
  next unless File.file?(path) && path.end_with?('.rb')
  begin
    output.write(find_external_code(path).to_s + "\n") unless find_external_code(path).nil?
  rescue Exception => ex
    errors.write(File.expand_path(path) + " => #{ex.class}" + "\n")
  end
  progressbar.increment
end
