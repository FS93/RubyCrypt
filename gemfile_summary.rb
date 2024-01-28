# frozen_string_literal: true
require 'bundler'
require 'json'

without_groups = [:test, :development, :kerberos]
# load gems definition from Gemfile
definition = Bundler.definition
# filter groups
groups = definition.groups.reject { |g| without_groups.include?(g)}
# filter gems
gems = definition.specs_for(groups).to_a
# filter name & summary
gem_summaries = {}
gems.map { |gem| gem_summaries[gem.name] = gem.summary}

# write JSON file
File.open("/OUTPUT/PATH/gem_summaries.json", 'w') do |file|
  file.write(JSON.pretty_generate(gem_summaries))
end
