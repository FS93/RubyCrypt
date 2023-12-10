# frozen_string_literal: true

require_relative 'reverse_dependencies'
require_relative 'traverse'
require_relative 'export'



class Analyzer
  include Export

  SCAN_DIRECTORY = Dir.pwd # current directory
  EXPORT_DIR = "/Daten/Code/RubyCrypt/scans/"
  CRYPTO_GEMS = %w[openssl bcrypt attr_jncrypted lockbox rbnacl scrypt strongox cose encryptor digest]

  attr_reader :scan_dir, :export_dir, :gems

  def initialize(scan_dir = SCAN_DIRECTORY, export_dir = EXPORT_DIR, *gems)

    @scan_dir = scan_dir
    @export_dir = export_dir
    gems.empty? ? @gems = CRYPTO_GEMS : @gems = gems
  end

  def analyze(scan_dir = @scan_dir, gems = @gems)

    # calculate chains of reverse dependencies
    dependency_chains = why(gems)
    relevant_gems = Regexp.union(dependency_chains.inject(:+).uniq) unless dependency_chains.empty?

    # extract requirements from Ruby files in scan_dir & subdirectories
    requirements, errors = traverse(scan_dir)
    dependency_chains.empty? ? filtered_requirements = {} : filtered_requirements = requirements.filter { |gem, files| gem.to_s.match(relevant_gems)} unless dependency_chains.empty?



    # Export
    timestamp = Time.now.strftime('%Y-%m-%dT%H-%M-%S')

    data_to_export = {
      "dependency_chains" => dependency_chains,
      "requirements" => requirements,
      "filtered_requirements" => filtered_requirements,
      "errors" => errors
    }

    data_to_export.each do |filename, data|
      export_data(data, filename, @export_dir, timestamp)
    end

  end
end

analyzer = Analyzer.new(*ARGV)
analyzer.analyze