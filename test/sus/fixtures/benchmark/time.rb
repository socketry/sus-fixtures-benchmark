# frozen_string_literal: true

require "sus/fixtures/benchmark/time"

describe Sus::Fixtures::Benchmark::Time do
	it "returns a string representation of real time" do
		time = Sus::Fixtures::Benchmark::Time.new(1.0, 2.0, 3.0)
		expect(time.to_s).to be == "3.0s"
	end
	
	it "returns a detailed string representation" do
		time = Sus::Fixtures::Benchmark::Time.new(1.0, 2.0, 3.0)
		expect(time.inspect).to be == "#<Sus::Fixtures::Benchmark::Time user=1.0s system=2.0s real=3.0s>"
	end
	
	with ".measure" do
		it "measures the execution time of a block and returns a Time object" do
			time = Sus::Fixtures::Benchmark::Time.measure do
				sleep(0.01)
			end
			expect(time).to be_a(Sus::Fixtures::Benchmark::Time)
			expect(time.real).to be > 0
		end
	end
end
