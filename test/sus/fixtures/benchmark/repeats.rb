# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "sus/fixtures/benchmark/repeats"
require "sus/fixtures/benchmark/sampler"

describe Sus::Fixtures::Benchmark::Repeats do
	let(:sampler) {Sus::Fixtures::Benchmark::Sampler.new(minimum: 3)}
	let(:repeats) {Sus::Fixtures::Benchmark::Repeats.new(sampler)}
	
	describe "#exactly" do
		it "returns an Exactly instance" do
			result = repeats.exactly(100)
			expect(result).to be_a(Sus::Fixtures::Benchmark::Repeats::Exactly)
		end
		
		it "executes the block exactly the specified number of times" do
			execution_count = 0
			
			repeats.exactly(5).times do
				execution_count += 1
			end
			
			expect(execution_count).to be == 5
			expect(sampler.size).to be == 5
		end
		
		it "overrides convergence-based execution" do
			# Create a sampler that would normally require more samples to converge
			convergence_sampler = Sus::Fixtures::Benchmark::Sampler.new(minimum: 100, margin_of_error: 0.001)
			convergence_repeats = Sus::Fixtures::Benchmark::Repeats.new(convergence_sampler)
			
			execution_count = 0
			
			convergence_repeats.exactly(3).times do
				execution_count += 1
			end
			
			# Should execute exactly 3 times, not wait for convergence
			expect(execution_count).to be == 3
			expect(convergence_sampler.size).to be == 3
			expect(convergence_sampler).not.to be(:converged?)
		end
	end
	
	describe "#times" do
		it "executes until convergence when no fixed count is set" do
			execution_count = 0
			
			repeats.times do
				execution_count += 1
			end
			
			# Should execute until convergence (at least minimum samples)
			expect(execution_count).to be >= sampler.minimum
			expect(sampler).to be(:converged?)
		end
	end
end

describe Sus::Fixtures::Benchmark::Repeats::Exactly do
	let(:sampler) {Sus::Fixtures::Benchmark::Sampler.new(minimum: 3)}
	let(:exactly) {Sus::Fixtures::Benchmark::Repeats::Exactly.new(sampler, 5)}
	
	describe "#times" do
		it "executes exactly the fixed count" do
			execution_count = 0
			
			exactly.times do
				execution_count += 1
			end
			
			expect(execution_count).to be == 5
			expect(sampler.size).to be == 5
		end
		
		it "always executes the specified number of times regardless of convergence" do
			# Create a sampler that would converge quickly
			quick_sampler = Sus::Fixtures::Benchmark::Sampler.new(minimum: 2, margin_of_error: 0.5)
			quick_exactly = Sus::Fixtures::Benchmark::Repeats::Exactly.new(quick_sampler, 10)
			
			execution_count = 0
			
			quick_exactly.times do
				execution_count += 1
			end
			
			# Should execute exactly 10 times, even if convergence would happen sooner
			expect(execution_count).to be == 10
			expect(quick_sampler.size).to be == 10
		end
	end
end
