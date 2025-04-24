#!/usr/bin/env ruby
# frozen_string_literal: true

# Ruby's open classes and refinements are unique features not found in most languages
# This file demonstrates how to safely extend existing classes

# ===== Traditional Monkey Patching =====
# In Ruby, any class can be reopened and modified at any time
# This is often called "Monkey Patching"

puts "=== Traditional Monkey Patching ==="

# Original String class behavior
puts "Before monkey patching:"
puts "hello".reverse
# => "olleh"

# Monkey patch the String class to add a new method
class String
  def reverse
    "MONKEY PATCHED: #{self.chars.reverse.join}"
  end

  def shout
    self.upcase + "!"
  end
end

# After monkey patching, all strings are affected
puts "\nAfter monkey patching:"
puts "hello".reverse
# => "MONKEY PATCHED: olleh"
puts "hello".shout
# => "HELLO!"

# ===== The Problem with Monkey Patching =====
puts "\n=== The Problem with Monkey Patching ==="
puts "1. Global impact: affects ALL uses of the class"
puts "2. Can lead to unexpected behavior in libraries"
puts "3. Method conflicts are hard to debug"
puts "4. No versioning or scoping of changes"

# ===== Refinements: Safe Monkey Patching =====
# Refinements (introduced in Ruby 2.0) are a safer way to extend classes
# They allow you to limit the scope of modifications

puts "\n=== Refinements: Safe Monkey Patching ==="

# Define a module with refinements for String
module StringExtensions
  # This declares we're creating refinements for the String class
  refine String do
    # Override an existing method
    def reverse
      "REFINED: #{self.chars.reverse.join}"
    end
    
    # Add a new method
    def palindrome?
      self == self.chars.reverse.join
    end
  end
end

# Outside the scope of refinements, original behavior is preserved
puts "\nOutside refinement scope:"
puts "hello".reverse
# Still shows the monkey-patched version: "MONKEY PATCHED: olleh"

# Create a scope where refinements are active
module RefinementScope
  # Activate the refinements in this scope
  using StringExtensions
  
  def self.demonstrate
    puts "\nInside refinement scope:"
    puts "hello".reverse           # Uses refined version
    puts "level".palindrome?       # Uses new method from refinement
    puts "hello".palindrome?
  end
end

# Call the demonstration
RefinementScope.demonstrate

# ===== Class Reopening Best Practices =====
puts "\n=== Class Reopening Best Practices ==="

# 1. Use a namespace for your extensions
module MyApp
  # Reopen a class within your namespace to avoid conflicts
  class String
    def truncate(length = 10)
      return self if self.length <= length
      self[0...length] + "..."
    end
  end
  
  # Usage within your namespace
  def self.process_string(str)
    string_obj = String.new(str)
    string_obj.truncate(5)
  end
end

# This doesn't affect the global String class
puts "MyApp::String implements truncate: #{MyApp::String.instance_methods(false).include?(:truncate)}"
puts "Global String doesn't have truncate: #{!String.instance_methods(false).include?(:truncate)}"
puts "Using MyApp's version: #{MyApp.process_string('This is a long string')}"

# 2. Clearly document your extensions
class ::Integer
  # Add a method for currency formatting to Integer
  # @param symbol [String] The currency symbol to use
  # @return [String] The formatted currency string
  def to_currency(symbol = "$")
    "#{symbol}#{self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end

puts "\nDocumented extension:"
puts 1234567.to_currency
puts 1234567.to_currency("€")

# ===== Module Inclusion Patterns =====
puts "\n=== Module Inclusion Patterns ==="

# 1. Extension modules with included callback
module StringUtilities
  # This gets called when the module is included in a class
  def self.included(base)
    puts "StringUtilities being included in #{base}"
    
    # Extend the class with class methods
    base.extend(ClassMethods)
    
    # Add class-level functionality
    base.class_eval do
      # Add a class variable
      @@utility_count = 0
      
      # Add a class method using class_eval
      def self.increment_utility_count
        @@utility_count += 1
      end
      
      def self.utility_count
        @@utility_count
      end
    end
  end
  
  # Instance methods - automatically added to instances
  def palindrome?
    to_s == to_s.reverse
  end
  
  def vowel_count
    to_s.downcase.count("aeiou")
  end
  
  # Class methods - added via extend in included callback
  module ClassMethods
    def create_from_array(array)
      new(array.join)
    end
  end
end

# Create a class that includes our utility module
class EnhancedString < String
  include StringUtilities
end

puts "\nUsing module-enhanced class:"
es = EnhancedString.new("level")
puts "Is '#{es}' a palindrome? #{es.palindrome?}"
puts "Vowel count in '#{es}': #{es.vowel_count}"

# Use the class method added by the module
es2 = EnhancedString.create_from_array(["h", "e", "l", "l", "o"])
puts "Created from array: '#{es2}'"

# Increment and check the class variable
EnhancedString.increment_utility_count
EnhancedString.increment_utility_count
puts "Utility count: #{EnhancedString.utility_count}"

# ===== Safe Extension with Refinements vs Monkey Patching =====
puts "\n=== Safe Extension with Refinements vs Monkey Patching ==="

# Define a module that might conflict with other libraries
module ConflictingLibrary
  refine String do
    def process
      "Processed by ConflictingLibrary: #{self}"
    end
  end
end

module AnotherLibrary
  refine String do
    def process
      "Processed by AnotherLibrary: #{self}"
    end
  end
end

# Usage without conflicts
module UseLibraryOne
  using ConflictingLibrary
  
  def self.run
    puts "In UseLibraryOne: #{'test'.process}"
  end
end

module UseLibraryTwo
  using AnotherLibrary
  
  def self.run
    puts "In UseLibraryTwo: #{'test'.process}"
  end
end

# Both libraries can be used without conflict
UseLibraryOne.run
UseLibraryTwo.run

# ===== Namespace Management =====
puts "\n=== Namespace Management ==="

# Proper namespace hierarchy
module MyCompany
  module MyProduct
    module Utilities
      class StringProcessor
        def initialize(str)
          @string = str
        end
        
        def process
          @string.upcase
        end
      end
      
      # Nested refinements can be scoped to your namespace
      module StringRefinements
        refine String do
          def company_format
            "MyCompany - #{self}"
          end
        end
      end
    end
  end
end

# Usage with proper namespacing
processor = MyCompany::MyProduct::Utilities::StringProcessor.new("test")
puts "Processed: #{processor.process}"

# Using the namespaced refinement
module MyCompanyCode
  using MyCompany::MyProduct::Utilities::StringRefinements
  
  def self.demo
    puts "With company format: #{'Product Name'.company_format}"
  end
end

MyCompanyCode.demo

# ===== When to Use Each Approach =====
puts "\n=== When to Use Each Approach ==="
puts "Use Refinements when:"
puts "1. You need to modify core classes safely"
puts "2. You want to limit the scope of changes"
puts "3. You're building a library used by others"
puts "4. You need to avoid conflicts with other code"

puts "\nUse Namespaced Classes when:"
puts "1. You're creating entirely new functionality"
puts "2. You need to organize a large codebase"
puts "3. Your code might be used alongside other libraries"

puts "\nUse Module Inclusion when:"
puts "1. You want to add behavior to multiple classes"
puts "2. You're implementing a mixin pattern"
puts "3. You need to extend classes with both instance and class methods"

# ===== Real-world Example: Safe JSON Extensions =====
puts "\n=== Real-world Example: Safe JSON Extensions ==="

require 'json'

# Define refinements for safer JSON handling
module SafeJSON
  refine Object do
    def to_safe_json
      to_json
    rescue => e
      { error: "Could not convert to JSON: #{e.message}" }.to_json
    end
  end
  
  refine Hash do
    def to_safe_json
      transform_keys { |k| k.to_s }.to_json
    rescue => e
      { error: "Could not convert to JSON: #{e.message}" }.to_json
    end
  end
end

# Using the refinements
module JSONProcessor
  using SafeJSON
  
  def self.process(obj)
    puts "Safe JSON: #{obj.to_safe_json}"
  end
end

# Test with various objects
JSONProcessor.process({ key: "value", nested: { array: [1, 2, 3] } })
JSONProcessor.process(Time.now)  # A complex object

puts "\nOutside the JSONProcessor module, the to_safe_json method is not available:"
begin
  { key: "value" }.to_safe_json
rescue NoMethodError => e
  puts "Expected error: #{e.message}"
end

puts "\nThis demonstrates the localized nature of refinements, a unique Ruby feature!"

