# frozen_string_literal: true

require 'bundler'

# @param spec_set Bundler::SpecSet
# @param gem_name String
# @return Bundler::StubSpecification
def find_one_spec_in_set(spec_set, gem_name)
  specs = spec_set[gem_name]
  if specs.length > 1
    warn format(
      'Expected %s to match exactly 1 spec, got %d',
      gem_name,
      specs.length
    )
  end

  specs.first
end

# @param spec_set Bundler::SpecSet
# @param parent Bundler::StubSpecification
# @param path Array[Bundler::StubSpecification]
# @void
def traverse_specs(spec_set, parent, path = [parent])

  return if parent.nil?

  children = spec_set.select do |s|
    s.dependencies.any? do |d|
      d.type == :runtime && d.name == parent.name
    end
  end

  if children.empty?
    $relevant_paths << path.map(&:name)
  else
    children.each do |child|
      traverse_specs(spec_set, child, [child].concat(path))
    end
  end
end

# @param gem_names Strings
# @void
def why(gem_names)

  runtime = Bundler.load
  spec_set = runtime.specs # delegates to Bundler::Definition#specs
  $relevant_paths = []

  gem_names.each do |gem|
    spec = find_one_spec_in_set(spec_set, gem) # extracts gem from spec_set
    traverse_specs(spec_set, spec)
  end
  $relevant_paths
end
