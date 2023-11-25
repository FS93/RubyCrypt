# frozen_string_literal: true

require 'bundler'
# def exec(_command, args)
#   if args.length == 1
#     why(args.first)
#   else
#     warn 'Usage: bundle why gemname'
#   end
# end

# @param spec_set Bundler::SpecSet
# @param gem_name String
# @return Bundler::StubSpecification
def find_one_spec_in_set(spec_set, gem_name)
  specs = spec_set[gem_name]
  if specs.length != 1
    warn format(
           'Expected %s to match exactly 1 spec, got %d',
           gem_name,
           specs.length
         )
  end

  specs.first
end

# @param path Array[Bundler::StubSpecification]
# @void
# def print_path(path)
#   puts path.map(&:name).join(' , ')
# end

# @param gem_names Strings
# @void
def why(gem_names)
  runtime = Bundler.load
  spec_set = runtime.specs # delegates to Bundler::Definition#specs
  $relevant_paths = []

  gem_names.each do |gem|
    spec = find_one_spec_in_set(spec_set, gem)
    traverse(spec_set, spec)
  end
  return $relevant_paths
end

# @param spec_set Bundler::SpecSet
# @param parent Bundler::StubSpecification
# @param path Array[Bundler::StubSpecification]
# @void
def traverse(spec_set, parent, path = [parent])

  children = spec_set.select do |s|
    s.dependencies.any? do |d|
      d.type == :runtime && d.name == parent.name
    end
  end


  if children.empty?
    # relevant_dependencies = path.to_h { |dep| [dep.name, path.last.name] }
    # puts relevant_dependencies
    # print_path(path)
    $relevant_paths << path.map(&:name)
  else
    children.each do |child|
      traverse(spec_set, child, [child].concat(path))
    end

  end
end

why(ARGV)
