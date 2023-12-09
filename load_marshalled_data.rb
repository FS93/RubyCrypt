# frozen_string_literal: true

require 'parser'

$requirements = Marshal.load(File.read('requirements', mode: 'rb'))
$filtered_requirements = Marshal.load(File.read('filtered_requirements', mode: 'rb'))
$errors = Marshal.load(File.read('errors', mode: 'rb'))
# filter for requirements whose path does not contain 'vendor' (implementation of gems reside in .../gitlab/vendor/**)
if $filtered_requirements.nil?
  $not_in_vendor_directory = nil
else
  $not_in_vendor_directory =  $filtered_requirements.transform_values { |files| files.filter { |file| not file[/vendor/]}}.filter{ |key, value| not value.empty?}
end

