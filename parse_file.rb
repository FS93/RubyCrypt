# frozen_string_literal: true
require 'parser/current'

class ExternalCodeFinder < Parser::AST::Processor
  @@commands = [:require, :require_relative, :load, :autoload]

  def initialize
    @required = []
    super
  end

  attr_accessor :required, :path

  def on_send(node)
    if node.children[0] == nil && @@commands.include?(node.children[1])
      # TODO properly extract the argument of the relevant commands ('children' might contain another AST)
      @required << node.children[2].children[0]
    end
    super
  end
end

class Hash
  def store_append(key, value)
    if self.has_key? key
      self[key] = self[key].to_a.append(value)
    else
      self.store(key, [value])
    end
  end
end

def find_external_code (path)
  # TODO parse_file puts diagnostics to STDERR - redirect them to a diagnostics file (with Ruby logger?)
  ast = Parser::CurrentRuby.parse_file(path)

  visitor = ExternalCodeFinder.new
  visitor.process(ast)

  return_hash = {}

  unless visitor.required.empty?
    visitor.required.each do |requirement|
      return_hash.store_append(requirement, path)
    end
    return_hash
  end
end
