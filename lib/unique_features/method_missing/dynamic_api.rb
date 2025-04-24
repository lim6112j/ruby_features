#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby's method_missing is one of its most powerful metaprogramming features
# This file demonstrates advanced uses of dynamic method handling

# ===== Basic method_missing Example =====
# method_missing is called when Ruby can't find a method on an object
class DynamicFinder
  def initialize(data)
    @data = data
  end
  
  # Called when a method that doesn't exist is invoked
  def method_missing(method_name, *arguments, &block)
    puts "Called undefined method: #{method_name} with args: #{arguments.inspect}"
    
    # We can inspect the method name and decide what to do
    if method_name.to_s.start_with?('find_by_')
      # Extract the attribute name from the method name
      attribute = method_name.to_s.sub('find_by_', '')
      
      # Find items matching the attribute
      find_items(attribute, arguments.first)
    else
      # If we can't handle this method, we should call super
      # This maintains the expected behavior for truly undefined methods
      super
    end
  end
  
  # It's good practice to override respond_to_missing? when you override method_missing
  # This makes reflection work correctly
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('find_by_') || super
  end
  
  private
  
  def find_items(attribute, value)
    @data.select { |item| item[attribute.to_sym] == value }
  end
end

# Example usage of dynamic finder
people = [
  { name: 'Alice', age: 30, city: 'New York' },
  { name: 'Bob', age: 25, city: 'Boston' },
  { name: 'Charlie', age: 35, city: 'New York' },
  { name: 'David', age: 30, city: 'Chicago' }
]

finder = DynamicFinder.new(people)
puts "=== Dynamic Finder Example ==="
puts "Finding by name: #{finder.find_by_name('Alice').inspect}"
puts "Finding by age: #{finder.find_by_age(30).inspect}"
puts "Finding by city: #{finder.find_by_city('New York').inspect}"

# Check if we properly implemented respond_to?
puts "\nDoes finder respond to find_by_name?: #{finder.respond_to?(:find_by_name)}"
puts "Does finder respond to unknown_method?: #{finder.respond_to?(:unknown_method)}"

# ===== Ghost Methods with Method Chaining =====
# Ghost methods are methods that don't physically exist but are handled via method_missing
# This pattern allows for expressive method chaining
class QueryBuilder
  def initialize
    @conditions = []
  end
  
  def method_missing(method_name, *arguments)
    if method_name.to_s =~ /^where_(.+)$/
      field = $1
      value = arguments.first
      @conditions << { field: field, value: value }
      self # Return self for method chaining
    elsif method_name == :execute
      execute_query
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s =~ /^where_(.+)$/ || method_name == :execute || super
  end
  
  private
  
  def execute_query
    "SELECT * FROM table WHERE #{build_where_clause}"
  end
  
  def build_where_clause
    @conditions.map { |c| "#{c[:field]} = '#{c[:value]}'" }.join(' AND ')
  end
end

puts "\n=== Method Chaining with Ghost Methods ==="
query = QueryBuilder.new
                    .where_name('Alice')
                    .where_age(30)
                    .where_active(true)
                    .execute
puts "Generated query: #{query}"

# ===== Dynamic Proxy Pattern =====
# method_missing can be used to implement a proxy that forwards calls to another object
class ServiceProxy
  def initialize(service)
    @service = service
    @call_count = Hash.new(0)
  end
  
  def method_missing(method_name, *arguments, &block)
    if @service.respond_to?(method_name)
      # Track method calls
      @call_count[method_name] += 1
      
      # Log the call
      puts "Calling '#{method_name}' on service (call ##{@call_count[method_name]})"
      
      # Measure execution time
      start_time = Time.now
      result = @service.send(method_name, *arguments, &block)
      end_time = Time.now
      
      puts "Call to '#{method_name}' took #{(end_time - start_time) * 1000}ms"
      
      result
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    @service.respond_to?(method_name) || super
  end
  
  def call_stats
    @call_count
  end
end

# A simple service to proxy
class UserService
  def find_user(id)
    # Simulate a database query
    sleep(0.1)
    { id: id, name: "User#{id}", email: "user#{id}@example.com" }
  end
  
  def update_user(id, attributes)
    # Simulate a database update
    sleep(0.2)
    { id: id, updated: true, attributes: attributes }
  end
end

puts "\n=== Dynamic Proxy Pattern ==="
service = UserService.new
proxy = ServiceProxy.new(service)

user = proxy.find_user(123)
puts "Found user: #{user.inspect}"

result = proxy.update_user(123, { name: "Updated User" })
puts "Update result: #{result.inspect}"

# Try to call the same method again
user = proxy.find_user(456)
puts "Found another user: #{user.inspect}"

puts "Call stats: #{proxy.call_stats.inspect}"

# ===== Metaprogramming with define_method =====
# Instead of using method_missing, we can dynamically define methods at runtime
class DynamicMethods
  # Class method to dynamically define instance methods
  def self.define_finder_methods(attributes)
    attributes.each do |attribute|
      # Define a method for each attribute
      define_method("find_by_#{attribute}") do |value|
        @data.select { |item| item[attribute] == value }
      end
    end
  end
  
  def initialize(data)
    @data = data
  end
end

# Create a specialized class with generated methods
class PersonFinder < DynamicMethods
  # Define finder methods for specific attributes
  define_finder_methods([:name, :age, :city])
end

puts "\n=== Metaprogramming with define_method ==="
person_finder = PersonFinder.new(people)

# Now these are real methods, not method_missing calls
puts "Finding by name: #{person_finder.find_by_name('Bob').inspect}"
puts "Finding by age: #{person_finder.find_by_age(30).inspect}"

# Check methods - these are actual methods now, not ghost methods
puts "Methods defined on PersonFinder: #{PersonFinder.instance_methods(false).inspect}"

# ===== Method Missing vs Define Method =====
puts "\n=== Method Missing vs Define Method ==="
puts "Pros of method_missing:"
puts "1. Handles unlimited method names without explicitly defining them"
puts "2. Good for creating very flexible DSLs"
puts "3. Great for proxying to unknown objects"

puts "\nPros of define_method:"
puts "1. Better performance (no method_missing lookup chain)"
puts "2. Better IDE support and code analysis"
puts "3. Clearer for other developers what methods are available"
puts "4. Works with reflection tools like respond_to?"

# ===== Advanced Example: ActiveRecord-like Query Builder =====
class Model
  def self.table_name
    name.downcase + 's'
  end
  
  def self.where(conditions = {})
    QueryObject.new(self, conditions)
  end
  
  def self.all
    QueryObject.new(self)
  end
  
  def self.find(id)
    where(id: id).first
  end
end

class QueryObject
  def initialize(model_class, conditions = {})
    @model_class = model_class
    @conditions = conditions
    @order_clauses = []
    @limit_value = nil
    @offset_value = nil
  end
  
  # Dynamic method chaining for ordering
  def method_missing(method_name, *args)
    if method_name.to_s =~ /^order_by_(.+)$/
      field = $1
      direction = args.first || :asc
      @order_clauses << { field: field, direction: direction }
      self
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s =~ /^order_by_(.+)$/ || super
  end
  
  def limit(value)
    @limit_value = value
    self
  end
  
  def offset(value)
    @offset_value = value
    self
  end
  
  def to_sql
    sql = "SELECT * FROM #{@model_class.table_name}"
    
    # Add WHERE clause if conditions exist
    if @conditions.any?
      where_clause = @conditions.map { |k, v| "#{k} = '#{v}'" }.join(' AND ')
      sql += " WHERE #{where_clause}"
    end
    
    # Add ORDER BY clause if ordering exists
    if @order_clauses.any?
      order_clause = @order_clauses.map { |o| "#{o[:field]} #{o[:direction]}" }.join(', ')
      sql += " ORDER BY #{order_clause}"
    end
    
    # Add LIMIT and OFFSET if specified
    sql += " LIMIT #{@limit_value}" if @limit_value
    sql += " OFFSET #{@offset_value}" if @offset_value
    
    sql
  end
  
  # Simulate executing the query
  def execute
    puts "Executing SQL: #{to_sql}"
    # In a real ORM, this would return actual data
    []
  end
  
  # Methods that execute the query
  def first
    limit(1).execute.first
  end
  
  def count
    execute.size
  end
  
  def each(&block)
    execute.each(&block)
  end
end

class User < Model
end

puts "\n=== ActiveRecord-like Query Builder ==="
query = User.where(active: true, role: 'admin')
            .order_by_created_at(:desc)
            .order_by_name
            .limit(10)
            .offset(20)

puts query.to_sql

puts "\nThis demonstrates the power of Ruby's dynamic method handling capabilities!"

