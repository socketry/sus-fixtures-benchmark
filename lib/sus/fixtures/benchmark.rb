require 'distribution'

module Sus
	module Fixtures
		module Benchmark
			def self.included(base)
				base.extend(Context)
			end
			
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
			
			class Samples
				Sample = Struct.new(:repeats, :time)
				
				def initialize
					@samples = []
				end
				
				def measure(confidence: 0.95, &block)
					Time.measure do
						block.call(1)
					end
					
					repeats = 1
					until converged?(confidence)
						time = Time.measure do
							block.call(repeats)
						end
						
						add(repeats, time)
						repeats *= 2
					end
				end
				
				private def format_duration(seconds)
					if seconds < 1e-6
						"#{(seconds * 1e9).round(2)}ns"
					elsif seconds < 1e-3
						"#{(seconds * 1e6).round(2)}μs"
					elsif seconds < 1
						"#{(seconds * 1e3).round(2)}ms"
					else
						"#{seconds.round(2)}s"
					end
				end
				
				def summary
					"#{self.size} repeats, mean: #{format_duration(self.mean.real)}, standard deviation: #{format_duration(self.standard_deviation)}, standard error: #{format_duration(self.standard_error)}"
				end
				
				def add(repeats, time)
					@samples << Sample.new(repeats, time)
				end
				
				def size
					@samples.sum(&:repeats)
				end
				
				def mean
					if @samples.any?
						@samples.map(&:time).sum(Time.new) / @samples.sum(&:repeats)
					end
				end
				
				def variance
					if @samples.any?
						mean = self.mean
						
						@samples.map{|sample| (sample.time - mean) ** 2}.sum(Time.new) / self.size
					end
				end
				
				def standard_deviation
					if variance = self.variance
						Math.sqrt(self.variance.real)
					end
				end
				
				def standard_error
					if standard_deviation = self.standard_deviation
						self.standard_deviation / Math.sqrt(self.size)
					end
				end
				
				def converged?(confidence = 0.95, margin_of_error = 0.01)
					return false if @samples.size < 2
					
					# Calculate the current mean and standard error
					mean = self.mean.real
					standard_error = self.standard_error
					
					if mean && standard_error
						# Calculate the critical value (z-score) based on the confidence level
						z_score = Distribution::Normal.p_value((1 + confidence) / 2.0)
						
						# Calculate the margin of error
						current_margin_of_error = z_score * standard_error
						
						# Check if the margin of error is within the acceptable range
						current_margin_of_error <= margin_of_error
					end
				end
			end
			
			module Measure
				def self.build(parent, description, unique: true, &block)
					base = Class.new(parent)
					base.extend(self)
					base.description = description
					base.identity = Identity.nested(parent.identity, base.description, unique: unique)
					base.set_temporary_name("#{self}[#{description}]")
					
					if block_given?
						base.define_method(:run, &block)
					end
					
					return base
				end
				
				def leaf?
					true
				end
				
				def print(output)
					self.superclass.print(output)
					
					output.write(" measure ", :it, self.description, :reset, " ", :identity, self.identity.to_s, :reset)
				end
				
				def to_s
					"measure #{self.description}"
				end
				
				def call(assertions)
					assertions.nested(self, identity: self.identity, isolated: true, measure: true) do |assertions|
						instance = self.new(assertions)
						
						samples = Samples.new
						
						instance.around do
							samples.measure(&instance.method(:run))
						end
						
						assertions.inform(samples.summary)
					end
				end
			end
			
			module Context
				# Measures the execution time of a block.
				# 
				# Returns the time it took to execute the block.
				def measure(...)
					add Measure.build(self, ...)
				end
			end
		end
	end
end