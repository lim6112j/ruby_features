#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby's block_given? method is a powerful tool for creating flexible APIs
# This file demonstrates various ways to use block_given? effectively

# ===== Basic block_given? Usage =====
# block_given? returns true if the method was called with a block
puts "=== Basic block_given? Usage ==="

def check_for_block
  if block_given?
    puts "A block was given! Let's call it:"
    yield
  else
    puts "No block was given."
  end
end

puts "Calling without a block:"
check_for_block

puts "\nCalling with a block:"
check_for_block { puts "  Hello from the block!" }

# ===== Common Patterns with block_given? =====
puts "\n=== Common Patterns with block_given? ==="

# Pattern 1: Default behavior with optional customization via block
def process_data(data)
  # Apply default transformation
  result = data.upcase
  
  # Allow optional customization via block
  result = yield(result) if block_given?
  
  result
end

text = "hello world"
puts "Default processing: #{process_data(text)}"
puts "Custom processing: #{process_data(text) { |r| r.gsub('L', '*') }}"

# Pattern 2: Return an enumerator if no block given
def custom_each(array)
  # Return an enumerator if no block is given
  return to_enum(:custom_each, array) unless block_given?
  
  array.each_with_index do |item, index|
    yield item, index
  end
end

array = [10, 20, 30]

puts "\nUsing with a block:"
custom_each(array) { |item, index| puts "  Item at #{index}: #{item}" }

puts "\nUsing as an enumerator:"
enum = custom_each(array)
puts "  Got an enumerator: #{enum.class}"
puts "  First item and index: #{enum.next.inspect}"

# Pattern 3: Different handling based on block presence
def find_or_create(id)
  item = find_item(id)
  
  if item
    # Item found - pass to block if given
    return block_given? ? yield(item) : item
  else
    # Item not found - create new
    new_item = { id: id, created_at: Time.now }
    yield new_item if block_given?
    new_item
  end
end

def find_item(id)
  # Mock database lookup
  return { id: id, name: "Existing Item" } if id < 100
  nil
end

puts "\nFinding existing item without a block:"
puts "  #{find_or_create(42)}"

puts "\nFinding existing item with a transformation block:"
puts "  #{find_or_create(42) { |item| item[:transformed] = true; item }}"

puts "\nCreating new item that doesn't exist:"
puts "  #{find_or_create(999) { |item| item[:name] = "New Item"; item }}"

# ===== Control Flow with block_given? =====
puts "\n=== Control Flow with block_given? ==="

# Early return vs continued processing
def process_with_control_flow(data)
  return "No data provided" if data.nil?
  
  # Process the data
  processed = "Processed: #{data}"
  
  # If a block is given, let it transform the data and return
  return yield(processed) if block_given?
  
  # Otherwise continue with default flow
  "#{processed} (default)"
end

puts "With no block: #{process_with_control_flow("hello")}"
puts "With block: #{process_with_control_flow("hello") { |d| "Custom: #{d}" }}"
puts "With nil data: #{process_with_control_flow(nil)}"

# Using block_given? in a loop
def repeat_until(max_iterations = 10)
  iterations = 0
  
  until iterations >= max_iterations
    iterations += 1
    
    # If a block is given, yield to it and check its return value
    if block_given?
      result = yield iterations
      break if result == :stop
    else
      puts "Iteration #{iterations}"
    end
  end
  
  iterations
end

puts "\nRepeat with no block (default behavior):"
repeat_until(3)

puts "\nRepeat with a block that controls flow:"
iterations = repeat_until(10) do |i|
  puts "  Custom iteration #{i}"
  :stop if i >= 3
end
puts "  Completed #{iterations} iterations"

# ===== block_given? Best Practices and Gotchas =====
puts "\n=== block_given? Best Practices and Gotchas ==="

# Best Practice 1: Always check before yielding
def safe_yield
  if block_given?
    yield
  else
    "No block given"
  end
end

puts "Safe yield with block: #{safe_yield { "Block called" }}"
puts "Safe yield without block: #{safe_yield}"

# Best Practice 2: Return self for method chaining when appropriate
class ChainableProcessor
  def initialize(value)
    @value = value
  end
  
  def transform
    if block_given?
      @value = yield(@value)
      self  # Return self for method chaining
    else
      self  # Still return self even without a block
    end
  end
  
  def format
    if block_given?
      yield(@value)
    else
      @value.to_s
    end
  end
end

processor = ChainableProcessor.new(10)
puts "\nMethod chaining example:"
puts "  " + processor
  .transform { |v| v * 2 }
  .transform { |v| v + 5 }
  .format { |v| "The result is #{v}" }

# Gotcha 1: block_given? doesn't check block parameters
def gotcha_parameters
  puts "  Block given? #{block_given?}"
  yield(1, 2, 3) if block_given?
end

puts "\nGotcha: Mismatched block parameters:"
gotcha_parameters { |a| puts "  Block expects 1 param but got more: #{a}" }

# Gotcha 2: block_given? is method-specific
def outer_method
  puts "  Outer method - block given? #{block_given?}"
  inner_method
end

def inner_method
  puts "  Inner method - block given? #{block_given?}"
  yield if block_given?
end

puts "\nGotcha: block_given? is method-specific:"
outer_method { puts "  This block is for outer_method" }

# ===== Real-world Examples =====
puts "\n=== Real-world Examples ==="

# Example 1: Configuration DSL
class Configuration
  attr_accessor :api_key, :timeout, :retries
  
  def initialize
    @api_key = nil
    @timeout = 30
    @retries = 3
    
    # Apply configuration block if given
    yield(self) if block_given?
  end
  
  def validate!
    raise "API key is required" unless @api_key
    raise "Timeout must be positive" unless @timeout.positive?
    raise "Retries must be non-negative" unless @retries >= 0
    true
  end
end

puts "Example 1: Configuration DSL"
config = Configuration.new do |c|
  c.api_key = "secret_key_123"
  c.timeout = 60
  c.retries = 5
end

puts "  Config valid? #{config.validate!}"
puts "  Settings: API key: #{config.api_key}, Timeout: #{config.timeout}, Retries: #{config.retries}"

# Example 2: Resource handling with automatic cleanup
def with_resource(resource_name)
  # Acquire the resource
  puts "  Opening #{resource_name}..."
  resource = "#{resource_name}_handle"
  
  if block_given?
    begin
      # Let the caller use the resource via the block
      result = yield resource
      puts "  Got result: #{result}"
    ensure
      # Always clean up, even if an exception occurs
      puts "  Closing #{resource_name}..."
    end
  else
    # If no block given, just return the resource
    # (caller is responsible for cleanup)
    puts "  No block given, returning resource without automatic cleanup"
    resource
  end
end

puts "\nExample 2: Resource handling with automatic cleanup"
puts "With a block (automatic cleanup):"
with_resource("database") { |db| "Processed data from #{db}" }

puts "\nWithout a block (manual cleanup):"
resource = with_resource("file")
puts "  Using #{resource} manually"
puts "  Manually closing resource..."

# Example 3: Custom enumeration with filtering
class FilteredCollection
  def initialize(items)
    @items = items
  end
  
  def each_item
    return to_enum(:each_item) unless block_given?
    
    @items.each do |item|
      # Skip items that start with underscore (private items)
      next if item.to_s.start_with?('_')
      
      # Yield matching items to the block
      yield item
    end
  end
  
  def with_prefix(prefix)
    return to_enum(:with_prefix, prefix) unless block_given?
    
    @items.each do |item|
      # Skip items that don't start with the prefix
      next unless item.to_s.start_with?(prefix)
      
      # Yield matching items to the block
      yield item
    end
  end
end

puts "\nExample 3: Custom enumeration with filtering"
collection = FilteredCollection.new(['apple', 'banana', '_hidden', 'apricot', '_private', 'avocado'])

puts "Items without block (returns enumerator):"
enum = collection.each_item
puts "  #{enum.class}: #{enum.to_a}"

puts "\nItems with block:"
collection.each_item { |item| puts "  - #{item}" }

puts "\nFiltered with prefix 'a':"
collection.with_prefix('a') { |item| puts "  - #{item}" }

# ===== Block_given? vs Lambda Pattern =====
puts "\n=== block_given? vs Lambda Pattern ==="

def with_block_check(value)
  transformed = value.to_s.upcase
  block_given? ? yield(transformed) : transformed
end

def with_lambda(value, transformer = ->(v) { v })
  transformed = value.to_s.upcase
  transformer.call(transformed)
end

puts "Using block_given?: #{with_block_check("hello") { |v| v.reverse }}"
puts "Using lambda parameter: #{with_lambda("hello", ->(v) { v.reverse })}"
puts "Using default lambda: #{with_lambda("hello")}"

puts "\nThis demonstrates the versatility of Ruby's block_given? method!"
