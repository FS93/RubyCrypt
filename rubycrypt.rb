# frozen_string_literal: true

require_relative 'reverse_dependencies'
require_relative 'traverse'
require_relative 'export'
include Export


SCAN_DIRECTORY = Dir.pwd # current directory
EXPORT_DIR = "/Daten/Code/RubyCrypt/scans/"
CRYPTO_GEMS = %w[
	attr_encrypted
	bcrypt
	cose
	doorkeeper
	encryptor
	ed25519
	json-jwt
	lockbox 
	net-ssh 
	net-scp
	oauth
	oauth2
	openssl
	openssl-signature_algorithm
  rbnacl
	scrypt
	ssh_data 
]

class Analyzer

  def initialize(scan_dir = SCAN_DIRECTORY, export_dir = EXPORT_DIR, *gems)

    @scan_dir = scan_dir
    @export_dir = export_dir
    gems.empty? ? @gems = CRYPTO_GEMS : @gems = gems
  end

  attr_reader :scan_dir, :export_dir, :gems
  def analyze(scan_dir = @scan_dir, gems = @gems)

    # calculate chains of reverse dependencies
    dependency_chains = why(gems)

    # RegExp to search for require statements
    # gem naming convention (see https://guides.rubygems.org/name-your-gem/): "-" in the gem name (e.g. net-ssh) turn into "/" in the require statement (require net/ssh)
    relevant_gems = Regexp.union(dependency_chains.inject(:+).uniq.map {|gem| gem.gsub("-", "/")}) unless dependency_chains.empty?

    # extract requirements from Ruby files in scan_dir & subdirectories
    requirements, errors = traverse(scan_dir)
    dependency_chains.empty? ? filtered_requirements = {} : filtered_requirements = requirements.filter { |gem, files| gem.to_s.match(relevant_gems)} unless dependency_chains.empty?



    # Export
    data_to_export = {
      "config" => {
        "SCAN_DIR" => scan_dir,
        "CRYPTO_GEMS" => gems
      },
      "dependency_chains" => dependency_chains,
      "requirements" => requirements,
      "filtered_requirements" => filtered_requirements,
      "errors" => errors
    }

    data_to_export.each do |filename, data|
      export_data(data, filename, @export_dir)
    end

  end
end

# Parse Command Line Arguments
# TODO Use OptionParser for proper handling of Command Line Arguments
case ARGV.size
when 0
  scan_dir = SCAN_DIRECTORY
  export_dir = EXPORT_DIR
  gems = CRYPTO_GEMS
when 1
  scan_dir = ARGV[0]
  export_dir = EXPORT_DIR
  gems = CRYPTO_GEMS
when 2
  scan_dir = ARGV[0]
  export_dir = ARGV[1]
  gems = CRYPTO_GEMS
else
  scan_dir = ARGV[0]
  export_dir = ARGV[1]
  gems = ARGV[2..ARGV.size]
end

# Create export directory with timestamp
export_dir_with_timestamp = Export.create_directories(export_dir,Time.now.strftime('%Y-%m-%dT%H-%M-%S'))
analyzer = Analyzer.new(scan_dir, export_dir_with_timestamp, *gems)

# redirect stderr to error_log file
original_stderr = $stderr.dup
$stderr.reopen(export_dir_with_timestamp.join('error_log').to_s, 'w')
$stderr.sync = true
analyzer.analyze
$stderr.reopen(original_stderr)
