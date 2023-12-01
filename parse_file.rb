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
      @required << node.children[2].children[0]
    end
    super
  end
end

def find_external_code (path)
  code = File.read(path)
  ast = Parser::CurrentRuby.parse(code)

  visitor = ExternalCodeFinder.new
  visitor.process(ast)

  return_hash = {path.to_sym => visitor.required}
  p return_hash
end

find_external_code(ARGV[0])