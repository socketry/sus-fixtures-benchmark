# frozen_string_literal: true

#
# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "time"

module Sus
	module Fixtures
		module Benchmark
			# Represents a benchmarking helper that executes a block multiple times, collecting timing samples until statistical convergence is reached.
			class Repeats
				# Initializes a new {Repeats} object with a sampler to collect timing data.
				# @parameter samples [Sampler] The sampler object to collect timing data.
				def initialize(samples)
					@samples = samples
				end
				
				# Samples the execution time of the given block and adds the result to the sampler.
				# @parameter block [Proc] The block to benchmark.
				private def sample!(block)
					time = Benchmark::Time.measure do
						block.call
					end
					@samples.add(time.real)
				end
				
				# Repeatedly executes the block until the sampler reports convergence.
				# @parameter block [Proc] The block to benchmark.
				def times(&block)
					until @samples.converged?
						sample!(block)
					end
				end
			end
		end
	end
end
