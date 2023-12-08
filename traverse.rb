# frozen_string_literal: true
require 'find'
require_relative './parse_file.rb'
require 'ruby-progressbar'
require 'pathname'

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


def traverse (directory_path)

  data = {}
  errors = {}

  number_of_ruby_files = Dir.glob("**/*.rb", File::FNM_DOTMATCH, base: directory_path).length
  puts "Ruby Files to analyze: " + number_of_ruby_files.to_s

  progressbar = ProgressBar.create(:total => number_of_ruby_files, :throttle_rate => 2)

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
