#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby's operator overloading capabilities are uniquely flexible
# This file demonstrates advanced operator overloading techniques

# ===== Basic Operator Overloading =====
# Ruby allows you to define most operators as methods
puts "=== Basic Operator Overloading ==="

class Vector2D
  attr_reader :x, :y
  
  def initialize(x, y)
    @x = x
    @y = y
  end
  
  # Addition operator
  def +(other)
    Vector2D.new(@x + other.x, @y + other.y)
  end
  
  # Subtraction operator
  def -(other)
    Vector2D.new(@x - other.x, @y - other.y)
  end
  
  # Multiplication operator (scalar)
  def *(scalar)
    Vector2D.new(@x * scalar, @y * scalar)
  end
  
  # Division operator (scalar)
  def /(scalar)
    raise ZeroDivisionError if scalar.zero?
    Vector2D.new(@x / scalar, @y / scalar)
  end
  
  # Unary minus (negation)
  def -@
    Vector2D.new(-@x, -@y)
  end
  
  # Unary plus (identity)
  def +@
    self
  end
  
  # Equality operator
  def ==(other)
    return false unless other.is_a?(Vector2D)
    @x == other.x && @y == other.y
  end
  
  # String representation
  def to_s
    "(#{@x}, #{@y})"
  end
end

# Using vector operations
v1 = Vector2D.new(3, 4)
v2 = Vector2D.new(1, 2)

puts "v1 = #{v1}"
puts "v2 = #{v2}"
puts "v1 + v2 = #{v1 + v2}"
puts "v1 - v2 = #{v1 - v2}"
puts "v1 * 2 = #{v1 * 2}"
puts "v1 / 2 = #{v1 / 2}"
puts "-v1 = #{-v1}"
puts "v1 == v2: #{v1 == v2}"
puts "v1 == Vector2D.new(3, 4): #{v1 == Vector2D.new(3, 4)}"

# ===== The Spaceship Operator and Comparable =====
# The <=> operator is the basis for all comparison in Ruby
puts "\n=== The Spaceship Operator and Comparable ==="

class Temperature
  include Comparable

  attr_reader :celsius
  
  def initialize(celsius)
    @celsius = celsius
  end
  
  # Define the spaceship operator
  def <=>(other)
    return nil unless other.is_a?(Temperature)
    @celsius <=> other.celsius
  end
  
  # Implement custom behavior for equality
  def ==(other)
    return false unless other.is_a?(Temperature)
    @celsius == other.celsius
  end
  
  # Convert to Fahrenheit
  def to_fahrenheit
    (@celsius * 9.0/5.0) + 32
  end
  
  # String representation
  def to_s
    "#{@celsius}°C (#{to_fahrenheit.round(1)}°F)"
  end
end

# Using temperature comparisons
freezing = Temperature.new(0)
boiling = Temperature.new(100)
warm = Temperature.new(25)

puts "freezing = #{freezing}"
puts "boiling = #{boiling}"
puts "warm = #{warm}"
puts "freezing < boiling: #{freezing < boiling}"
puts "warm.between?(freezing, boiling): #{warm.between?(freezing, boiling)}"
puts "boiling > warm: #{boiling > warm}"
puts "[freezing, boiling, warm].sort: #{[freezing, boiling, warm].sort.map(&:to_s)}"

# ===== Array Access Operators =====
# Ruby's [] and []= operators are highly flexible
puts "\n=== Array Access Operators ==="

class Grid
  def initialize(width, height)
    @width = width
    @height = height
    @cells = Array.new(width * height, 0)
  end
  
  # Single index access - treat as 1D array
  def [](index)
    @cells[index]
  end
  
  # Array setter
  def []=(index, value)
    @cells[index] = value
  end
  
  # Matrix-style coordinates access - accepts [x, y]
  def [](x, y)
    return nil if x < 0 || x >= @width || y < 0 || y >= @height
    @cells[y * @width + x]
  end
  
  # Matrix-style setter
  def []=(x, y, value)
    return if x < 0 || x >= @width || y < 0 || y >= @height
    @cells[y * @width + x] = value
  end
  
  # Support for ranges in indexing
  def [](range)
    return @cells[range] if range.is_a?(Range)
    
    # If it's a row specification like :row, 3
    if range.is_a?(Array) && range.size == 2 && range[0] == :row
      row = range[1]
      return nil if row < 0 || row >= @height
      start_idx = row * @width
      return @cells[start_idx...(start_idx + @width)]
    end
    
    # Default to normal behavior
    if range.is_a?(Array) && range.size == 2
      x, y = range
      return self[x, y]
    end
    
    # If we got here, we don't know how to handle this index
    nil
  end
  
  # String representation
  def to_s
    result = ""
    
    @height.times do |y|
      @width.times do |x|
        result << "#{self[x, y]} "
      end
      result << "\n"
    end
    
    result
  end
end

# Using grid with different access patterns
grid = Grid.new(3, 3)

# Set values using various indexing methods
grid[0, 0] = 1
grid[1, 1] = 5
grid[2, 2] = 9
grid[0, 2] = 7

puts "Grid after setting values:"
puts grid

# Access individual elements
puts "Value at [0, 0]: #{grid[0, 0]}"
puts "Value at [1, 1]: #{grid[1, 1]}"

# Access a row
puts "Second row: #{grid[:row, 1].inspect}"

# ===== Bitwise Operators =====
# Ruby allows overloading of bitwise operators
puts "\n=== Bitwise Operators ==="

class Permissions
  NONE = 0
  READ = 1      # 001
  WRITE = 2     # 010
  EXECUTE = 4   # 100
  ALL = 7       # 111
  
  attr_reader :value
  
  def initialize(value = NONE)
    @value = value
  end
  
  # Bitwise OR (|) - combine permissions
  def |(other)
    if other.is_a?(Permissions)
      Permissions.new(@value | other.value)
    else
      Permissions.new(@value | other)
    end
  end
  
  # Bitwise AND (&) - check common permissions
  def &(other)
    if other.is_a?(Permissions)
      Permissions.new(@value & other.value)
    else
      Permissions.new(@value & other)
    end
  end
  
  # Bitwise XOR (^) - toggle permissions
  def ^(other)
    if other.is_a?(Permissions)
      Permissions.new(@value ^ other.value)
    else
      Permissions.new(@value ^ other)
    end
  end
  
  # Bitwise NOT (~) - invert permissions (within our 3-bit space)
  def ~
    Permissions.new(~@value & ALL)
  end
  
  # Check if permission is set
  def has?(permission)
    if permission.is_a?(Permissions)
      (@value & permission.value) == permission.value
    else
      (@value & permission) == permission
    end
  end
  
  # String representation
  def to_s
    perms = []
    perms << "read" if has?(READ)
    perms << "write" if has?(WRITE)
    perms << "execute" if has?(EXECUTE)
    perms.empty? ? "none" : perms.join(", ")
  end
end

# Using permission operations
read_only = Permissions.new(Permissions::READ)
write_only = Permissions.new(Permissions::WRITE)
read_write = read_only | write_only
exec_only = Permissions.new(Permissions::EXECUTE)
all_perms = Permissions.new(Permissions::ALL)
no_write = ~write_only

puts "read_only: #{read_only}"
puts "write_only: #{write_only}"
puts "read_write: #{read_write}"
puts "exec_only: #{exec_only}"
puts "all_perms: #{all_perms}"
puts "no_write: #{no_write}"

puts "read_write has read? #{read_write.has?(Permissions::READ)}"
puts "read_write has execute? #{read_write.has?(Permissions::EXECUTE)}"
puts "read_only & write_only: #{read_only & write_only}" # Should be none

# ===== Custom Operator for Function Composition =====
puts "\n=== Function Composition with Operators ==="

class Function
  attr_reader :proc
  
  def initialize(proc)
    @proc = proc
  end
  
  # Apply the function to a value
  def call(value)
    @proc.call(value)
  end
  
  # Function composition operator (>>)
  # f >> g is the function that computes g(f(x))
  def >>(other)
    Function.new(-> (x) { other.call(self.call(x)) })
  end
  
  # Reversed function composition (<<)
  # f << g is the function that computes f(g(x))
  def <<(other)
    Function.new(-> (x) { self.call(other.call(x)) })
  end
  
  # Create a new function by applying another function element-wise to arrays
  def %(other)
    Function.new(-> (arr) {
      arr.is_a?(Array) ? arr.map { |x| other.call(x) } : other.call(arr)
    })
  end
  
  # String representation (show as lambda)
  def to_s
    "Function"
  end
end

# Create some simple functions
double = Function.new(->(x) { x * 2 })
increment = Function.new(->(x) { x + 1 })
square = Function.new(->(x) { x * x })

# Using function composition
double_then_increment = double >> increment
increment_then_square = increment >> square
complex_function = double >> square >> increment

# Apply functions
puts "double(5) = #{double.call(5)}"
puts "increment(5) = #{increment.call(5)}"
puts "double_then_increment(5) = #{double_then_increment.call(5)}"  # (5*2)+1 = 11
puts "increment_then_square(5) = #{increment_then_square.call(5)}"  # (5+1)^2 = 36
puts "complex_function(3) = #{complex_function.call(3)}"  # ((3*2)^2)+1 = 37

# Apply a function to each element in an array
map_function = double % increment
puts "map_function([1, 2, 3]) = #{map_function.call([1, 2, 3]).inspect}"  # [3, 5, 7]

# ===== Ruby's Special Operators =====
puts "\n=== Ruby's Special Operators ==="

class CustomHash
  def initialize
    @data = {}
  end
  
  # Call operator - makes an object callable like a proc
  def call(key)
    @data[key]
  end
  
  # Safe navigation operator emulation
  def &.(key)
    @data.key?(key) ? @data[key] : nil
  end
  
  # Element reference (read)
  def [](key)
    @data[key]
  end
  
  # Element assignment (write)
  def []=(key, value)
    @data[key] = value
  end
  
  # Element existence check
  def include?(key)
    @data.key?(key)
  end
  alias_method :===, :include?
  
  # String representation
  def to_s
    @data.to_s
  end
  
  # Handled by method_missing for demo purposes
  def method_missing(name, *args)
    if name.to_s.end_with?('?')
      key = name.to_s.chop.to_sym
      return @data.key?(key)
    elsif name.to_s.end_with?('=') && args.size == 1
      key = name.to_s.chop.to_sym
      return @data[key] = args.first
    elsif @data.key?(name)
      return @data[name]
    end
    super
  end
  
  def respond_to_missing?(name, include_private = false)
    name.to_s.end_with?('?') || name.to_s.end_with?('=') || @data.key?(name) || super
  end
end

# Using special operators
hash = CustomHash.new
hash[:name] = "Ruby"
hash[:version] = 3.2
hash.language = "Programming"  # Using method_missing

puts "hash: #{hash}"
puts "hash[:name]: #{hash[:name]}"
puts "hash.call(:version): #{hash.call(:version)}"
puts "hash.language: #{hash.language}"
puts "hash.language?: #{hash.language?}"
puts "hash.missing?: #{hash.missing?}"
puts "hash === :name: #{hash === :name}"  # Case equality operator

# ===== Real-world Examples =====
puts "\n=== Real-world Examples ==="

# Example 1: Money operations
class Money
  attr_reader :amount, :currency
  
  def initialize(amount, currency = "USD")
    @amount = amount.to_f.round(2)
    @currency = currency
  end
  
  # Addition
  def +(other)
    ensure_currency_match(other)
    Money.new(@amount + other.amount, @currency)
  end
  
  # Subtraction
  def -(other)
    ensure_currency_match(other)
    Money.new(@amount - other.amount, @currency)
  end
  
  # Multiplication by scalar
  def *(scalar)
    Money.new(@amount * scalar, @currency)
  end
  
  # Division by scalar
  def /(scalar)
    raise ZeroDivisionError if scalar.zero?
    Money.new(@amount / scalar, @currency)
  end
  
  # Equality
  def ==(other)
    return false unless other.is_a?(Money)
    @amount == other.amount && @currency == other.currency
  end
  
  # Comparison
  def <=>(other)
    return nil unless other.is_a?(Money) && @currency == other.currency
    @amount <=> other.amount
  end
  
  # Negation
  def -@
    Money.new(-@amount, @currency)
  end
  
  # String representation
  def to_s
    "#{format("%.2f", @amount)} #{@currency}"
  end
  
  # Method to allocate money across parts (e.g., splitting a bill)
  def allocate(parts)
    raise ArgumentError, "Cannot allocate to empty parts" if parts.empty?
    
    # Convert to cents to avoid floating point errors
    cents = (@amount * 100).round
    cents_per_part = cents / parts.sum
    
    # Allocate the cents according to the parts
    allocated_cents = parts.map { |part| (cents_per_part * part).floor }
    
    # Add the remainder to the first part
    remainder = cents - allocated_cents.sum
    allocated_cents[0] += remainder
    
    # Convert back to Money objects
    allocated_cents.map { |cents| Money.new(cents / 100.0, @currency) }
  end
  
  private
  
  def ensure_currency_match(other)
    unless other.is_a?(Money) && other.currency == @currency
      raise ArgumentError, "Currency mismatch: #{@currency} vs #{other.currency}"
    end
  end
end

# Using money operations
salary = Money.new(5000, "USD")
bonus = Money.new(1000, "USD")
total = salary + bonus

puts "Salary: #{salary}"
puts "Bonus: #{bonus}"
puts "Total: #{total}"
puts "Monthly pay: #{total / 12}"
puts "Negative value: #{-bonus}"

# Allocating money (like splitting a bill)
bill = Money.new(100, "USD")
shares = bill.allocate([1, 2, 1])  # Split in ratio 1:2:1

puts "Bill: #{bill}"
puts "Split 1:2:1 = #{shares.map(&:to_s).join(', ')}"
puts "Sum of parts equals whole: #{shares.reduce(Money.new(0, "USD"), :+) == bill}"

# Example 2: Matrix operations
puts "\n=== Matrix Operations ==="

class Matrix
  attr_reader :rows, :cols, :data
  
  def initialize(data)
    @data = data
    @rows = data.size
    @cols = data.first.size
  end
  
  # Addition
  def +(other)
    ensure_same_dimensions(other)
    
    result = Array.new(@rows) { Array.new(@cols, 0) }
    
    @rows.times do |i|
      @cols.times do |j|
        result[i][j] = @data[i][j] + other.data[i][j]
      end
    end
    
    Matrix.new(result)
  end
  
  # Subtraction
  def -(other)
    ensure_same_dimensions(other)
    
    result = Array.new(@rows) { Array.new(@cols, 0) }
    
    @rows.times do |i|
      @cols.times do |j|
        result[i][j] = @data[i][j] - other.data[i][j]
      end
    end
    
    Matrix.new(result)
  end
  
  # Scalar multiplication
  def *(scalar)
    return matrix_multiply(scalar) if scalar.is_a?(Matrix)
    
    result = Array.new(@rows) { Array.new(@cols, 0) }
    
    @rows.times do |i|
      @cols.times do |j|
        result[i][j] = @data[i][j] * scalar
      end
    end
    
    Matrix.new(result)
  end
  
  # Matrix multiplication
  def matrix_multiply(other)
    raise ArgumentError, "Matrix dimensions don't match for multiplication" unless @cols == other.rows
    
    result = Array.new(@rows) { Array.new(other.cols, 0) }
    
    @rows.times do |i|
      other.cols.times do |j|
        result[i][j] = (0...@cols).sum { |k| @data[i][k] * other.data[k][j] }
      end
    end
    
    Matrix.new(result)
  end
  
  # Transpose (using the ** operator for demonstration)
  def **(scalar)
    return transpose if scalar == -1
    raise ArgumentError, "Only ** -1 is supported for transpose"
  end
  
  def transpose
    result = Array.new(@cols) { Array.new(@rows, 0) }
    
    @rows.times do |i|
      @cols.times do |j|
        result[j][i] = @data[i][j]
      end
    end
    
    Matrix.new(result)
  end
  
  # Element access
  def [](i, j)
    @data[i][j]
  end
  
  # String representation
  def to_s
    @data.map { |row| row.join(", ") }.join("\n")
  end
  
  private
  
  def ensure_same_dimensions(other)
    unless other.is_a?(Matrix) && other.rows == @rows && other.cols == @cols
      raise ArgumentError, "Matrix dimensions don't match"
    end
  end
end

# Using matrix operations
matrix_a = Matrix.new([
  [1, 2],
  [3, 4]
])

matrix_b = Matrix.new([
  [5, 6],
  [7, 8]
])

matrix_c = Matrix.new([
  [1, 2, 3],
  [4, 5, 6]
])

puts "Matrix A:\n#{matrix_a}"
puts "\nMatrix B:\n#{matrix_b}"
puts "\nA + B:\n#{matrix_a + matrix_b}"
puts "\nA - B:\n#{matrix_a - matrix_b}"
puts "\nA * 2:\n#{matrix_a * 2}"
puts "\nA * B:\n#{matrix_a * matrix_b}"
puts "\nTranspose of A (A ** -1):\n#{matrix_a ** -1}"

# Example 3: Time Range operations
puts "\n=== Time Range Operations ==="

class TimeRange
  attr_reader :start_time, :end_time
  
  def initialize(start_time, end_time)
    @start_time = start_time
    @end_time = end_time
    validate_range
  end
  
  # Range intersection operator
  def &(other)
    return nil unless other.is_a?(TimeRange)
    
    new_start = [@start_time, other.start_time].max
    new_end = [@end_time, other.end_time].min
    
    return nil if new_start > new_end
    TimeRange.new(new_start, new_end)
  end
  
  # Range union operator (only works for overlapping or adjacent ranges)
  def |(other)
    return nil unless other.is_a?(TimeRange)
    return nil if @end_time < other.start_time || @start_time > other.end_time
    
    new_start = [@start_time, other.start_time].min
    new_end = [@end_time, other.end_time].max
    
    TimeRange.new(new_start, new_end)
  end
  
  # Check if time is in range
  def ===(time)
    time >= @start_time && time <= @end_time
  end
  
  # Duration (in seconds)
  def duration
    @end_time - @start_time
  end
  
  # Shift the range by a given number of seconds
  def >>(seconds)
    TimeRange.new(@start_time + seconds, @end_time + seconds)
  end
  
  # Shift the range back by a given number of seconds
  def <<(seconds)
    TimeRange.new(@start_time - seconds, @end_time - seconds)
  end
  
  # String representation
  def to_s
    "#{@start_time.strftime('%H:%M')} - #{@end_time.strftime('%H:%M')}"
  end
  
  private
  
  def validate_range
    raise ArgumentError, "End time must be after start time" if @end_time < @start_time
  end
end

# Using time range operations
require 'time'

morning = TimeRange.new(Time.parse("08:00"), Time.parse("12:00"))
afternoon = TimeRange.new(Time.parse("13:00"), Time.parse("17:00"))
lunch = TimeRange.new(Time.parse("11:30"), Time.parse("13:30"))
meeting = TimeRange.new(Time.parse("09:00"), Time.parse("10:00"))

puts "Morning: #{morning}"
puts "Afternoon: #{afternoon}"
puts "Lunch: #{lunch}"
puts "Meeting: #{meeting}"

morning_lunch_overlap = morning & lunch
puts "Morning & Lunch overlap: #{morning_lunch_overlap || 'No overlap'}"

lunch_afternoon_overlap = lunch & afternoon
puts "Lunch & Afternoon overlap: #{lunch_afternoon_overlap || 'No overlap'}"

morning_meeting_overlap = morning & meeting
puts "Morning & Meeting overlap: #{morning_meeting_overlap || 'No overlap'}"

check_time = Time.parse("09:30")
puts "Is #{check_time.strftime('%H:%M')} in the meeting? #{meeting === check_time}"

delayed_meeting = meeting >> 3600  # Shift by 1 hour
puts "Delayed meeting: #{delayed_meeting}"

# ===== Operator Safety Guidelines =====
puts "\n=== Operator Safety Guidelines ==="
puts "1. Always maintain expected operator semantics:"
puts "   - + should perform addition or combination"
puts "   - * should perform multiplication or repetition"
puts "   - == should test value equality, not identity"

puts "\n2. Be consistent with Ruby's built-in types:"
puts "   - Follow how String, Array, Hash implement operators"
puts "   - Use to_* methods for type conversions"
puts "   - Implement <=> for comparison"

puts "\n3. Handle edge cases gracefully:"
puts "   - Return nil for incompatible operations"
puts "   - Provide clear error messages"
puts "   - Accept similar types where appropriate"

puts "\n4. Prefer composition over inheritance for operators:"
puts "   - Enclose complex behaviors in methods"
puts "   - Keep operator methods small and focused"
puts "   - Document behavior that's not obvious"

# ===== Operator Overloading Best Practices =====
puts "\n=== Operator Overloading Best Practices ==="

class BestPractices
  def self.demonstrate
    puts "1. Use operators to make code more readable:"
    puts "   Good: total = price + tax"
    puts "   Bad: total = price.add(tax)"
    puts ""
    
    puts "2. Avoid surprising behavior:"
    puts "   Good: 'hello' + 'world' => 'helloworld'"
    puts "   Bad: 'hello' + 'world' => 42"
    puts ""
    
    puts "3. Return the same type when appropriate:"
    puts "   Good: Money + Money => Money"
    puts "   Bad: Money + Money => Float"
    puts ""
    
    puts "4. Only redefine operators when their meaning is obvious:"
    puts "   Good: Vector * scalar => scaled Vector"
    puts "   Bad: Customer * Product => Invoice"
    puts ""
    
    puts "5. Implement related operators together:"
    puts "   If you implement +, also consider -"
    puts "   If you implement <, also implement >, <=, >="
    puts ""
    
    puts "6. Test corner cases:"
    puts "   Test with zero, negative values, nils"
    puts "   Test with empty collections"
    puts "   Test with extreme values"
  end
end

BestPractices.demonstrate

puts "\nThis demonstrates Ruby's uniquely flexible operator overloading capabilities!"
