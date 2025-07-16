# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "time"

module Sus
	module Fixtures
		module Benchmark
			# Represents a benchmarking helper that executes a block multiple times, collecting timing samples until statistical convergence is reached.
			class Repeats
				# Initializes a new {Repeats} object with a sampler to collect timing data.
				# @parameter sampler [Sampler] The sampler object to collect timing data.
				def initialize(sampler)
					@sampler = sampler
				end
				
				# Samples the execution time of the given block and adds the result to the sampler.
				# @parameter block [Proc] The block to benchmark.
				private def sample!(block)
					time = Benchmark::Time.measure do
						block.call
					end
					@sampler.add(time.real)
				end
				
				# Repeatedly executes the block until the sampler reports convergence.
				# @parameter block [Proc] The block to benchmark.
				def times(&block)
					until @sampler.converged?
						sample!(block)
					end
				end

				# Represents a benchmarking helper that executes a block a fixed number of times.
				class Exactly
					# Initializes a new {Exactly} object with a sampler and a fixed count.
					# @parameter sampler [Sampler] The sampler object to collect timing data.
					# @parameter count [Integer] The exact number of times to execute the block.
					def initialize(sampler, count)
						@sampler = sampler
						@count = count
					end
					
					# Samples the execution time of the given block and adds the result to the sampler.
					# @parameter block [Proc] The block to benchmark.
					private def sample!(block)
						time = Benchmark::Time.measure do
							block.call
						end
						@sampler.add(time.real)
					end
					
					# Executes the block exactly the specified number of times.
					# @parameter block [Proc] The block to benchmark.
					def times(&block)
						@count.times do
							sample!(block)
						end
					end
				end
				
				# Sets a fixed number of times to execute the block, returning a new {Exactly} instance.
				# @parameter count [Integer] The exact number of times to execute the block.
				# @returns [Exactly] A new instance that will execute the block exactly the specified number of times.
				def exactly(count)
					Exactly.new(@sampler, count)
				end
			end
		end
	end
end
