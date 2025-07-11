# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require_relative "time"

module Sus
	module Fixtures
		module Benchmark
			class Repeats
				def initialize(samples)
					@samples = samples
				end
				
				private def sample!(block)
					time = Benchmark::Time.measure do
						block.call
					end
					
					@samples.add(time.real)
				end
				
				def times(&block)
					until @samples.converged?
						sample!(block)
					end
				end
			end
		end
	end
end
