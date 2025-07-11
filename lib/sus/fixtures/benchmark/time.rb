# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module Sus
	module Fixtures
		module Benchmark
			class Time
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

				def initialize(user = 0.0, system = 0.0, real = 0.0)
					@user = user
					@system = system
					@real = real
				end

				attr :user
				attr :system
				attr :real

				def to_s
					"#{self.real}s"
				end

				def inspect
					"#<#{self.class} user=#{self.user}s system=#{self.system}s real=#{self.real}s>"
				end

				def +(other)
					self.class.new(
						self.user + other.user,
						self.system + other.system,
						self.real + other.real,
					)
				end

				def /(other)
					self.class.new(
						self.user / other,
						self.system / other,
						self.real / other,
					)
				end

				def *(other)
					self.class.new(
						self.user * other,
						self.system * other,
						self.real * other,
					)
				end

				def -(other)
					self.class.new(
						self.user - other.user,
						self.system - other.system,
						self.real - other.real,
					)
				end

				def **(other)
					self.class.new(
						self.user ** other,
						self.system ** other,
						self.real ** other,
					)
				end
			end
		end
	end
end
