# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require_relative "benchmark/version"

require_relative "benchmark/sampler"
require_relative "benchmark/repeats"

module Sus
	module Fixtures
		module Benchmark
			def self.included(base)
				base.extend(Context)
			end
			
			module Measure
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
				
				def leaf?
					true
				end
				
				def print(output)
					self.superclass.print(output)
					
					output.write(" measure ", :it, self.description, :reset, " ", :identity, self.identity.to_s, :reset)
				end
				
				def to_s
					"measure #{self.description}"
				end
				
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
			
			module Context
				# Measures the execution time of a block.
				# 
				# Returns the time it took to execute the block.
				def measure(...)
					add Measure.build(self, ...)
				end
			end
		end
	end
end
