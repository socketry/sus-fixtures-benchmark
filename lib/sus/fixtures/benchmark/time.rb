# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module Sus
	module Fixtures
		module Benchmark
			# Represents a timing sample for benchmarking, including user, system, and real time.
			class Time
				# Measures the execution time of a block, returning a new {Time} object with user, system, and real time.
				# @returns[Time] The measured timing sample.
				def self.measure
					t0, r0 = Process.times, Process.clock_gettime(Process::CLOCK_MONOTONIC)
					yield
					t1, r1 = Process.times, Process.clock_gettime(Process::CLOCK_MONOTONIC)
					
					self.new(
						t1.utime  - t0.utime,
						t1.stime  - t0.stime,
						r1 - r0,
					)
				end
				
				# Initializes a new {Time} object with user, system, and real time values.
				# @parameter user [Float] The user CPU time in seconds.
				# @parameter system [Float] The system CPU time in seconds.
				# @parameter real [Float] The real (wall clock) time in seconds.
				def initialize(user = 0.0, system = 0.0, real = 0.0)
					@user = user
					@system = system
					@real = real
				end
				
				# The user CPU time in seconds.
				# @returns[Float]
				attr :user
				# The system CPU time in seconds.
				# @returns[Float]
				attr :system
				# The real (wall clock) time in seconds.
				# @returns[Float]
				attr :real

				# Returns a string representation of the real time in seconds.
				# @returns[String]
				def to_s
					"#{self.real}s"
				end
				
				# Returns a detailed string representation of the timing sample.
				# @returns[String]
				def inspect
					"#<#{self.class} user=#{self.user}s system=#{self.system}s real=#{self.real}s>"
				end
			end
		end
	end
end
