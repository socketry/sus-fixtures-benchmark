# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2024-2025, by Samuel Williams.

require "sus/fixtures/benchmark"

describe Sus::Fixtures::Benchmark do
	include Sus::Fixtures::Benchmark
	
	measure "really slow" do |repeats|
		repeats.times do
			sleep(0.01)
		end
	end
	
	measure "slow" do |repeats|
		repeats.times do
			sleep(0.001)
		end
	end
	
	measure "fast" do |repeats|
		repeats.times do
			sleep(0.0001)
		end
	end
end
