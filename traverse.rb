# frozen_string_literal: true
require 'find'
require_relative './parse_file.rb'
require 'ruby-progressbar'
require 'pathname'

DIRECTORY = '/Daten/Code/gitlab/app'
SCAN_DIR = "/Daten/Code/RubyCrypt/scans/"
class Hash
  def store_join(another_hash)
    another_hash.each do |key, value|
      if self.has_key? key
        self[key] = self[key].to_a + value.to_a
      else
        # self.update(another_hash)
        self[key] = value.to_a
      end
    end
  end
end


def traverse (directory_path = DIRECTORY)

  data = {}
  errors = {}

  progressbar = ProgressBar.create(:total => 5151, :throttle_rate => 5)

  # traverse directory
  Find.find(directory_path) do |path|
    # filter for Ruby Files
    next unless File.file?(path) && path.end_with?('.rb')

    begin
      unless find_external_code(path).nil?
        data.store_join(find_external_code(path))
      end
    rescue Exception => ex
      errors.store_join({File.expand_path(path)=> [ex.class]})
    end
    progressbar.increment
  end

  # return
  return data, errors
end

def export_data (data, errors, scan_dir = SCAN_DIR)

  timestamp = Time.now.strftime('%Y-%m-%dT%H-%M-%S')

  # create directories
  scan_dir_path = Pathname.new(scan_dir)
  scan_dir_path.mkdir unless scan_dir_path.exist?
  scan_dir_path.join(timestamp).mkdir

  # write marshalled data to files data & errors
  File.open(scan_dir_path.join(timestamp,'data'), 'wb') do |file|
    file.write(Marshal.dump(data))
  end

  File.open(scan_dir_path.join(timestamp,'errors'), 'wb') do |file|
    file.write(Marshal.dump(errors))
  end
end

data, errors = traverse
export_data(data, errors)
