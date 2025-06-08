#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby symbols are unique identifiers that are particularly efficient
# This file demonstrates unique symbol features not found in most languages
require 'benchmark'
require 'objspace'

# ===== Symbols vs Strings: Memory Efficiency =====
# Symbols are interned, meaning identical symbols refer to the same object
puts "=== Symbol Interning and Memory Efficiency ==="

# Create 10000 identical strings
strings = Array.new(10000) { "hello_world" }

# Create 10000 identical symbols
symbols = Array.new(10000) { :hello_world }

# Memory usage and identity comparison
string_count = strings.map(&:object_id).uniq.count
symbol_count = symbols.map(&:object_id).uniq.count

puts "Number of unique objects for 10000 identical strings: #{string_count}"
puts "Number of unique objects for 10000 identical symbols: #{symbol_count}"

# Memory size comparison
string_memory = strings.sum { |s| s.object_id.size }
symbol_memory = symbols.sum { |s| s.object_id.size }

puts "Memory footprint ratio (approximate): Strings use #{string_memory / symbol_memory}x more memory"

# Symbol memory usage in detail
test_string = "hello_world"
test_symbol = :hello_world

puts "\nMemory usage:"
puts "String: #{ObjectSpace.memsize_of(test_string)} bytes"
puts "Symbol: #{ObjectSpace.memsize_of(test_symbol)} bytes"

# ===== Symbol Comparison Performance =====
# Symbols are much faster to compare than strings
puts "\n=== Symbol vs String Comparison Performance ==="

n = 1_000_000
Benchmark.bmbm do |x|
  x.report("String comparison:") do
    n.times do
      "hello_world" == "hello_world"
    end
  end

  x.report("Symbol comparison:") do
    n.times do
      :hello_world == :hello_world
    end
  end
end

# ===== Symbol to Proc =====
# The &:symbol syntax is a unique Ruby feature
puts "\n=== Symbol to Proc Operations ==="

names = ["John", "Paul", "George", "Ringo"]

# Traditional block approach
traditional_upcased = names.map { |name| name.upcase }

# Symbol to proc approach - unique to Ruby
symbol_upcased = names.map(&:upcase)

puts "Traditional block: #{traditional_upcased}"
puts "Symbol to proc: #{symbol_upcased}"

# Multiple methods with symbol-to-proc
puts "\nChaining symbol-to-proc operations:"
result = names
  .select(&:length)               # All non-empty strings
  .map(&:downcase)                # Convert to lowercase
  .sort_by(&:length)              # Sort by length
  .map { |s| "#{s} (#{s.length})" } # Add length info

puts result.inspect

# Performance comparison of Symbol#to_proc
puts "\nPerformance of Symbol#to_proc vs blocks:"

Benchmark.bmbm do |x|
  x.report("Traditional block:") do
    10_000.times do
      names.map { |name| name.upcase }
    end
  end

  x.report("Symbol to proc:") do
    10_000.times do
      names.map(&:upcase)
    end
  end
end

# ===== Symbol-based DSLs =====
# Symbols are great for creating expressive DSLs
puts "\n=== Symbol-based DSLs ==="

class HTMLBuilder
  def initialize
    @html = ""
  end

  # Method that accepts a symbol and a block
  def tag(name, attributes = {}, &block)
    # Convert symbol to string for tag name
    tag_name = name.to_s

    # Handle attributes
    attribute_string = attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')
    attribute_string = " " + attribute_string unless attribute_string.empty?

    # Open tag
    @html += "<#{tag_name}#{attribute_string}>"

    # Execute the block in context
    if block_given?
      if block.arity == 0
        # Block doesn't need a reference to this builder
        result = yield
        @html += result.to_s
      else
        # Block needs a reference to this builder
        yield self
      end
    end

    # Close tag
    @html += "</#{tag_name}>"

    self # Return self for method chaining
  end

  # Define common HTML tags using symbols
  [:div, :p, :span, :h1, :h2, :h3, :a, :img, :ul, :li, :table, :tr, :td].each do |tag_name|
    define_method(tag_name) do |attributes = {}, &block|
      tag(tag_name, attributes, &block)
    end
  end

  # Method for text content
  def text(content)
    @html += content.to_s
    self
  end

  # Convert to HTML string
  def to_s
    @html
  end
end

# Using the symbol-based DSL
builder = HTMLBuilder.new
builder.div(class: 'container') do |b|
  b.h1 { "Welcome to Ruby Symbols!" }
  b.p(id: 'intro') { "Symbols are efficient and powerful." }
  b.ul do |b|
    b.li { "Memory efficient" }
    b.li { "Fast comparison" }
    b.li { "Great for DSLs" }
  end
end

puts "Generated HTML from Symbol-based DSL:"
puts builder.to_s

# ===== Advanced Symbol Techniques with Metaprogramming =====
puts "\n=== Advanced Symbol Techniques with Metaprogramming ==="

class ModelSchema
  # Define fields using symbols
  def self.field(name, type = :string, options = {})
    @fields ||= {}
    @fields[name] = { type: type, options: options }

    # Define getter and setter methods using the symbol name
    define_method(name) do
      @attributes[name]
    end

    define_method("#{name}=") do |value|
      @attributes[name] = convert_value(value, type)
    end
  end

  def self.fields
    @fields || {}
  end

  def initialize(attributes = {})
    @attributes = {}

    # Initialize attributes using symbol keys
    attributes.each do |key, value|
      # Use public send to call the setter method
      public_send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def convert_value(value, type)
    case type
    when :integer
      value.to_i
    when :float
      value.to_f
    when :boolean
      !!value
    when :date
      value.is_a?(Date) ? value : Date.parse(value.to_s)
    else
      value.to_s
    end
  end

  def inspect
    "#<#{self.class.name} #{@attributes.inspect}>"
  end
end

# Define a model using the schema
class Person < ModelSchema
  field :name
  field :age, :integer
  field :active, :boolean, default: true
  field :salary, :float
end

puts "Model schema using symbols:"
puts "Defined fields: #{Person.fields.keys.inspect}"

# Create a new instance
person = Person.new(name: "John Doe", age: "30", salary: "75000.50")

puts "Generated instance methods from symbols:"
puts "Methods: #{Person.instance_methods(false).inspect}"
puts "Person: #{person.inspect}"
puts "Name: #{person.name}"
puts "Age: #{person.age} (#{person.age.class})"
puts "Salary: #{person.salary} (#{person.salary.class})"

# ===== Symbol-based Configuration =====
puts "\n=== Symbol-based Configuration ==="

def configure(options = {})
  # Default settings using symbols as keys
  defaults = {
    environment: :development,
    log_level: :info,
    max_connections: 5,
    timeout: 30,
    ssl: true
  }

  # Merge user options with defaults
  settings = defaults.merge(options)

  # Display settings
  settings.each do |key, value|
    puts "#{key}: #{value}"
  end

  settings
end

puts "Default configuration:"
configure

puts "\nCustom configuration:"
configure(environment: :production, log_level: :error, timeout: 60)

# ===== Symbol Handling in Ruby ====
puts "\n=== Unique Symbol Features ==="

# Symbols can be created from strings dynamically
dynamic_symbol = "user_#{rand(1000)}".to_sym
puts "Dynamic symbol: #{dynamic_symbol}"

# Symbols are guaranteed to be unique and immutable
symbol1 = :test_symbol
symbol2 = :test_symbol
puts "Same object? #{symbol1.object_id == symbol2.object_id}"

# Symbols can be converted to/from strings
puts "Symbol to string: #{:hello.to_s}"
puts "String to symbol: #{'hello'.to_sym}"

# The special %s notation for symbols
array_of_symbols = %i[red green blue yellow]
puts "Array of symbols using %i: #{array_of_symbols.inspect}"

# Symbol interpolation with %I
color = "purple"
interpolated_symbols = %I[red green blue #{color}]
puts "Interpolated symbols using %I: #{interpolated_symbols.inspect}"

# Getting all symbols from Ruby
some_symbols = Symbol.all_symbols.grep(/^test_/).first(5)
puts "Some symbols from Ruby: #{some_symbols.inspect}"

puts "\nThis demonstrates the unique power of Ruby symbols!"
