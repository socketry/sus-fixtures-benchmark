
require 'sus/fixtures/benchmark'
include Sus::Fixtures::Benchmark

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

measure "random" do |repeats|
	repeats.times do
		sleep(rand * 0.05 + 0.1)
	end
end
