# frozen_string_literal: true

require 'parser'
require 'pathname'

puts "Enter timestamp of scan directory"
timestamp = gets.chomp
Dir.chdir(Pathname('scans').join(timestamp))

$requirements = Marshal.load(File.read('requirements', mode: 'rb'))
$filtered_requirements = Marshal.load(File.read('filtered_requirements', mode: 'rb'))
$errors = Marshal.load(File.read('errors', mode: 'rb'))
# filter for requirements whose path does not contain 'vendor' (implementation of gems reside in .../vendor/bundle/**)
if $filtered_requirements.nil?
  $not_in_vendor_directory = nil
else
  $not_in_vendor_directory =  $filtered_requirements.transform_values { |files| files.filter { |file| not file[/vendor/]}}.filter{ |key, value| not value.empty?}
end

# Print statistics
puts "No. of requirements:\t\t\t\t " + $requirements.size.to_s
puts "|----having a cryptographic dependency:\t\t " + $filtered_requirements.size.to_s
puts "\t|----not in vendor/bundle:\t\t " + $not_in_vendor_directory.size.to_s