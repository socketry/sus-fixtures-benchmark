# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

require "sus/fixtures/benchmark/sampler"
require "sus/fixtures/benchmark/repeats"

describe Sus::Fixtures::Benchmark::Sampler do
	let(:sampler) {subject.new(minimum: 1000)}
	let(:repeats) {Sus::Fixtures::Benchmark::Repeats.new(sampler)}
	
	it "converges for a uniform random sleep between 0 and 0.001s" do
		# repeats.times do
		# 	sleep(rand * 0.001)
		# end
		
		# We simulate the above measurement:
		until sampler.converged?
			sampler.add(rand * 0.001)
		end
		
		mean_us = sampler.mean.real * 1_000_000
		stddev_us = sampler.standard_deviation * 1_000_000
		
		# Theoretical values for uniform [0, 1_000] μs
		expected_mean = 500.0
		expected_stddev = 288.7
		
		# Allow some noise:
		expect(mean_us).to be_within(100).of(expected_mean)
		expect(stddev_us).to be_within(50).of(expected_stddev)
		
		# We expect the sampler to have a reasonable number of samples:
		expect(sampler.size).to be > 1000
		
		# And we expect the sampler to have converged:
		expect(sampler).to be(:converged?)
	end
	
	it "formats durations < 1μs as nanoseconds" do
		sampler.add(0.0000005) # 0.5μs
		expect(sampler.to_s).to be =~ /500.0ns/
	end
	
	it "formats durations >= 1s as seconds" do
		sampler.add(1.5)
		expect(sampler.to_s).to be =~ /1\.5s/
	end
	
	with "#quantile" do
		it "raises ArgumentError for qn < 0.0" do
			expect {sampler.send(:quantile, -0.1)}.to raise_exception(ArgumentError, message: be =~ /qn must be in the range/)
		end
		
		it "raises ArgumentError for qn > 1.0" do
			expect {sampler.send(:quantile, 1.1)}.to raise_exception(ArgumentError, message: be =~ /qn must be in the range/)
		end
		
		it "returns 0.0 for qn = 0.5" do
			expect(sampler.send(:quantile, 0.5)).to be == 0.0
		end
		
		it "returns cached value for qn = 0.95" do
			expect(sampler.send(:quantile, 0.95)).to be == 1.6448536269514722
		end
		
		it "returns cached value for qn = 0.96" do
			expect(sampler.send(:quantile, 0.96)).to be == 1.7506860712521692
		end
		
		it "returns cached value for qn = 0.97" do
			expect(sampler.send(:quantile, 0.97)).to be == 1.8807936081512509
		end
		
		it "returns cached value for qn = 0.98" do
			expect(sampler.send(:quantile, 0.98)).to be == 2.0537489106318225
		end
		
		it "returns cached value for qn = 0.99" do
			expect(sampler.send(:quantile, 0.99)).to be == 2.3263478740408408
		end
		
		it "returns negative value for qn < 0.5" do
			result = sampler.send(:quantile, 0.1)
			expect(result).to be < 0.0
		end
	end
end
