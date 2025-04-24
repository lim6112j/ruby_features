#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby's block system is one of its most powerful and unique features
# This file demonstrates advanced uses of blocks, procs, and yield

# ===== Custom Enumerator with Blocks =====
# Ruby allows you to create custom enumeration methods that yield to blocks
class CustomCollection
  def initialize(elements)
    @elements = elements
  end

  # Basic enumeration method that yields each element to a block
  # This pattern is the foundation of Ruby's Enumerable mixin
  def each
    return enum_for(:each) unless block_given? # Return an Enumerator if no block given
    
    @elements.each do |element|
      yield element # 'yield' passes control to the block
    end
    
    self # Return self for method chaining
  end
  
  # Custom enumeration with transformation
  def each_transformed
    return enum_for(:each_transformed) unless block_given?
    
    @elements.each do |element|
      transformed = element.to_s.upcase
      yield transformed
    end
    
    self
  end
  
  # Enumeration with index and element - multiple yield parameters
  # This demonstrates how blocks can receive multiple arguments
  def each_with_custom_index
    return enum_for(:each_with_custom_index) unless block_given?
    
    @elements.each_with_index do |element, idx|
      custom_idx = idx * 10 # Some custom indexing logic
      yield element, custom_idx
    end
    
    self
  end
end

# ===== Different Block Syntaxes =====
collection = CustomCollection.new([1, 2, 3, 4, 5])

puts "=== Basic block syntax with do/end ==="
collection.each do |item|
  puts "Item: #{item}"
end

puts "\n=== Block syntax with braces ==="
collection.each { |item| puts "Item: #{item}" }

puts "\n=== Multi-line with braces - less common but valid ==="
collection.each { |item| 
  puts "Processing..."
  puts "Item: #{item}"
}

# ===== Block-to-Proc Conversion =====
# Ruby automatically converts blocks to Proc objects with the & operator
def process_with_multiple_blocks(items, &main_block)
  # Store the block as a Proc
  original_block = main_block
  
  # Create a new proc that modifies behavior
  modified_block = proc { |item| original_block.call(item * 2) }
  
  # Use the blocks
  items.each(&original_block)
  puts "---"
  items.each(&modified_block)
end

puts "\n=== Block to Proc conversion ==="
process_with_multiple_blocks([1, 2, 3]) { |n| puts "Number: #{n}" }

# ===== Block Local Variables =====
# Ruby 1.9+ allows you to specify block-local variables
puts "\n=== Block local variables ==="
outer_var = "Outside"
[1, 2, 3].each do |item; inner_var|
  inner_var = "Inside"  # This won't affect any variable outside the block
  puts "Item: #{item}, Outer: #{outer_var}, Inner: #{inner_var}"
end

begin
  puts "Inner var outside the block: #{inner_var}"
rescue NameError => e
  puts "As expected, inner_var is not accessible outside: #{e.message}"
end

# ===== Lambdas vs Procs =====
puts "\n=== Lambda vs Proc behavior ==="
# Lambdas check argument count, procs don't
lambda_obj = lambda { |x, y| puts "Lambda got #{x} and #{y}" }
proc_obj = proc { |x, y| puts "Proc got #{x} and #{y}" }

begin
  lambda_obj.call(1)
rescue ArgumentError => e
  puts "Lambda error: #{e.message}"
end

# Proc will work with fewer arguments (sets missing ones to nil)
proc_obj.call(1)

# Lambdas and procs handle 'return' differently
def proc_return_test
  puts "Before proc"
  my_proc = proc { return "Early return from proc" }
  my_proc.call
  puts "After proc - you won't see this"
  "Normal return"
end

def lambda_return_test
  puts "Before lambda"
  my_lambda = lambda { return "Early return from lambda" }
  result = my_lambda.call
  puts "After lambda - #{result}"
  "Normal return"
end

puts "\n=== Return behavior ==="
puts "Proc test result: #{proc_return_test}"
puts "Lambda test result: #{lambda_return_test}"

# ===== Method Objects =====
# Ruby lets you get a Method object and pass it like a proc
puts "\n=== Method objects ==="
def multiply(x, y)
  x * y
end

# Get a reference to the method
multiply_method = method(:multiply)

# Use it like a proc
result = [1, 2, 3, 4].map.with_index(&multiply_method)
puts "Multiplied array with index: #{result.inspect}"

# ===== Symbol to Proc =====
# The &:symbol syntax is unique to Ruby
puts "\n=== Symbol to Proc conversion ==="
names = ["John", "Paul", "George", "Ringo"]
upcased = names.map(&:upcase)  # Equivalent to { |n| n.upcase }
puts "Upcased names: #{upcased.inspect}"

lengths = names.map(&:length)  # Equivalent to { |n| n.length }
puts "Name lengths: #{lengths.inspect}"

# This is shorthand for:
# names.map { |name| name.upcase }

# ===== Practical Example: Custom DSL with blocks =====
puts "\n=== Custom DSL Example ==="
class HTMLBuilder
  def initialize
    @html = ""
  end
  
  def element(name)
    @html += "<#{name}>"
    yield if block_given?
    @html += "</#{name}>"
  end

  def text(content)
    @html += content
  end
  
  def to_s
    @html
  end
  
  # DSL method - allows nicer syntax for nested structures
  def method_missing(name, *args, &block)
    element(name, &block)
  end
end

# Using the DSL
builder = HTMLBuilder.new
builder.html do
  builder.head do
    builder.title do
      builder.text("My Page")
    end
  end
  builder.body do
    builder.h1 do
      builder.text("Welcome!")
    end
    builder.p do
      builder.text("This page was generated with Ruby blocks")
    end
  end
end

puts "Generated HTML:"
puts builder.to_s

puts "\nThis demonstrates the power and flexibility of Ruby blocks!"

