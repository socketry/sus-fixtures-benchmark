# frozen_string_literal: true

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
end
