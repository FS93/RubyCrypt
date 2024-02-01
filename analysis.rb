# frozen_string_literal: true

require 'parser'
require 'pathname'

puts "Enter timestamp of output directory"
timestamp = gets.chomp
Dir.chdir(Pathname('scans').join(timestamp))

$config = Marshal.load(File.read('config', mode: 'rb'))
$requirements = Marshal.load(File.read('requirements', mode: 'rb'))
$dependency_chains = Marshal.load(File.read('dependency_chains', mode: 'rb'))
$filtered_requirements = Marshal.load(File.read('filtered_requirements', mode: 'rb'))
$errors = Marshal.load(File.read('errors', mode: 'rb'))
# filter for requirements whose path does not contain 'vendor' (implementation of gems reside in .../vendor/bundle/**)
if $filtered_requirements.nil?
  $not_in_vendor_directory = nil
else
  $not_in_vendor_directory =  $filtered_requirements.transform_values { |files| files.filter { |file| not file[/vendor/]}}.filter{ |key, value| not value.empty?}
end

# Print statistics
class String
  def red; "\e[31m#{self}\e[0m" end
end
puts "\n"
puts "DEPENDENCY CHAINS".red
puts "\n"
puts "No. of searched crypto gems:\t\t\t " + $config["CRYPTO_GEMS"].size.to_s
puts "|----found in scan directory:\t\t\t " + $dependency_chains.map { |c| c.last}.uniq.size.to_s
puts "No. of transitive dependencies:\t\t\t " + $dependency_chains.reduce(:+).uniq.size.to_s
puts "\n\n"

puts "REQUIREMENTS".red
puts "\n"
puts "No. of distinct loading arguments:\t\t " + $requirements.size.to_s
puts "|----which are gems from dependency chains:\t " + $filtered_requirements.size.to_s
puts "\t|----which are not in vendor/bundle:\t " + $not_in_vendor_directory.size.to_s
puts "\n\n"
