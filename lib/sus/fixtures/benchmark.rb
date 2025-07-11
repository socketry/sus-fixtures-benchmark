# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require_relative "benchmark/version"

require_relative "benchmark/sampler"
require_relative "benchmark/repeats"

# Provides the top-level namespace for the Sus testing framework.
module Sus
	# Provides reusable fixtures for benchmarking code.
	module Fixtures
		# Provides benchmarking utilities for Sus fixtures.
		module Benchmark
			# Extends a test context with benchmarking helpers when included.
			# @parameter base [Class] The test context class to extend.
			def self.included(base)
				base.extend(Context)
			end
			
			# Provides a benchmarking measure for a test case.
			module Measure
				# Builds a new benchmarking measure class for a test case.
				# @parameter parent [Class] The parent test context class.
				# @parameter description [String] The description of the measure.
				# @parameter unique [Boolean] Whether the measure should have a unique identity.
				# @parameter block [Proc] The block to execute for the measure.
				# @returns [Class] The new measure class.
				def self.build(parent, description, unique: true, &block)
					base = Class.new(parent)
					base.extend(self)
					base.description = description
					base.identity = Identity.nested(parent.identity, base.description, unique: unique)
					base.set_temporary_name("#{self}[#{description}]")
					
					if block_given?
						base.define_method(:run, &block)
					end
					
					return base
				end
				
				# Returns true if this is a leaf measure.
				# @returns [Boolean]
				def leaf?
					true
				end
				
				# Prints the measure description to the output.
				# @parameter output [IO] The output stream.
				def print(output)
					self.superclass.print(output)
					output.write(" measure ", :it, self.description, :reset, " ", :identity, self.identity.to_s, :reset)
				end
				
				# Returns a string representation of the measure.
				# @returns [String]
				def to_s
					"measure #{self.description}"
				end
				
				# Executes the measure within the given assertions context.
				# @parameter assertions [Object] The assertions context.
				def call(assertions)
					assertions.nested(self, identity: self.identity, isolated: true, measure: true) do |assertions|
						instance = self.new(assertions)
						
						samples = Sampler.new
						repeats = Repeats.new(samples)
						
						instance.around do
							instance.run(repeats)
						end
						
						assertions.inform(samples.to_s)
					end
				end
			end
			
			# Provides benchmarking helpers for test contexts.
			module Context
				# Measures the execution time of a block and adds a benchmarking measure to the context.
				def measure(...)
					add Measure.build(self, ...)
				end
			end
		end
	end
end
