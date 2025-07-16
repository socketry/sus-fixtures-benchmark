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

	measure "fast", minimum: 100 do |repeats|
		repeats.times do
			sleep(0.0001)
		end

		expect(repeats.sampler.size).to be >= 100
	end
	
	describe Sus::Fixtures::Benchmark::Measure do
		let(:instance) {subject.build(Sus.base, "test")}
		
		with "#to_s" do
			it "returns a string representation of the measure" do
				expect(instance.to_s).to be == "measure test"
			end
		end
		
		with "#leaf?" do
			it "returns true for a leaf measure" do
				expect(instance).to be(:leaf?)
			end
		end
		
		with "#print" do
			let(:output) {Sus::Output.buffered}
			
			it "prints the measure description to the output" do
				instance.print(output)
				expect(output.string).to be(:include?, "measure test")
			end
		end
	end
end
