# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Samuel Williams.

module Sus
	module Fixtures
		module Benchmark
			# Represents a statistical sampler for benchmarking, collecting timing samples and computing statistics.
			class Sampler
				B = [
					1.570796288, 0.03706987906, -0.8364353589e-3,
					-0.2250947176e-3, 0.6841218299e-5, 0.5824238515e-5,
					-0.104527497e-5, 0.8360937017e-7, -0.3231081277e-8,
					0.3657763036e-10, 0.6936233982e-12
				]
				private_constant :B
				
				# Return the inverse CDF or P-value of the corresponding integral
				private def quantile(qn)
					if qn < 0.0 || qn > 1.0
						raise ArgumentError, "qn must be in the range [0, 1]"
					end
					
					# Let's cache the standard normal quantiles for common values:
					case qn
					when 0.5
						return 0.0
					when 0.95
						return 1.6448536269514722
					when 0.96
						return 1.7506860712521692
					when 0.97
						return 1.8807936081512509
					when 0.98
						return 2.0537489106318225
					when 0.99
						return 2.3263478740408408
					end
					
					w1 = qn
					w3 = -Math.log(4.0 * w1 * (1.0 - w1))
					w1 = B[0]
					
					1.upto(10) do |i|
						w1 += B[i] * w3**i
					end
					
					if qn >= 0.5
						return Math.sqrt(w1 * w3)
					else
						return -Math.sqrt(w1 * w3)
					end
				end
				
				# Initializes a new {Sampler} object with an optional minimum sample size, confidence level, and margin of error.
				# @parameter minimum [Integer] The minimum number of samples required before convergence can be determined (default: 8).
				# @parameter confidence [Float] The confidence level (default: 0.95). If we repeated this measurement process many times, % of the calculated intervals would include the true value we’re trying to estimate.
				# @parameter margin_of_error [Float] The acceptable margin of error relative to the mean (default: 0.02, e.g. ±2%).
				def initialize(minimum: 8, confidence: 0.95, margin_of_error: 0.02)
					@minimum = minimum
					@confidence = confidence
					@margin_of_error = margin_of_error
					
					# Calculate the z-score for the given confidence level:
					@z_score = quantile((1 + @confidence) / 2.0)
					
					# Welford's algorithm for calculating mean and variance in a single pass:
					@count = 0
					@mean = 0.0
					@variance_accumulator = 0.0
				end
				
				# The minimum number of samples required for convergence.
				# @returns [Integer]
				attr :minimum
				
				# Adds a new timing value to the sample set.
				# @parameter value [Float] The timing value to add (in seconds).
				def add(value)
					@count += 1
					delta = value - @mean
					@mean += delta / @count
					@variance_accumulator += delta * (value - @mean)
				end
				
				# Returns the number of samples collected.
				# @returns [Integer]
				def size
					@count
				end
				
				# Returns the mean (average) of the collected samples.
				# @returns [Float]
				def mean
					@mean
				end
				
				# Returns the variance of the collected samples.
				# @returns [Float | Nil] Returns nil if not enough samples.
				def variance
					if @count > 1
						@variance_accumulator / (@count)
					end
				end
				
				# Returns the standard deviation of the collected samples.
				# @returns [Float | Nil] Returns nil if not enough samples.
				def standard_deviation
					v = self.variance
					v ? Math.sqrt(v) : nil
				end
				
				# Returns the standard error of the mean for the collected samples.
				# @returns [Float | Nil] Returns nil if not enough samples.
				def standard_error
					sd = self.standard_deviation
					sd ? sd / Math.sqrt(@count) : nil
				end
				
				# Formats a duration in seconds as a human-readable string.
				# @parameter seconds [Float] The duration in seconds.
				# @returns [String]
				private def format_duration(seconds)
					if seconds.nil?
						return "N/A"
					end
					
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
				
				# Returns a summary string of the sample statistics.
				# @returns [String]
				def to_s
					"#{self.size} samples, mean: #{format_duration(self.mean)}, standard deviation: #{format_duration(self.standard_deviation)}, standard error: #{format_duration(self.standard_error)}"
				end
				
				# Determines if the sample size has converged based on the confidence level and margin of error.
				#
				# Sampling data is always subject to some degree of uncertainty, and we want to ensure that our sample size is sufficient to provide a reliable estimate of the true value we're trying to measure (e.g. the mean execution time of a block).
				#
				# The mean of the data is the average of all samples, and the standard error tells us how much the sampled mean is expected to vary from the true value. So a big standard error indicates that the mean is not very reliable, and a small standard error indicates that the mean is more reliable.
				#
				# We could use the standard error to compute convergence, but we also want to ensure that the margin of error is within an acceptable range relative to the mean. This is where the confidence level and margin of error come into play. In other words, the margin of error is a relative measure, and we want an absolute measurement by which to determine convergence.
				#
				# The typical way to express this is to say that we are "confident" that the true mean is within a certain margin of error relative to the measured mean. For example, if we have a mean of 100 seconds and a margin of error of 0.02, then we are saying that we are confident (with the specified confidence level) that the true mean is within ±2 seconds (2% of the mean) of our measured mean.
				#
				# When we say "confident", we are referring to a statistical confidence level, which is a measure of how likely it is that the true value lies within the margin of error if we repeated the benchmark many times. A common confidence level is 95%, which means that if we repeated the measurement process many times, 95% of the calculated intervals would include the true value we’re trying to estimate, in other words, there is a 5% chance that the true value lies outside the margin of error.
				#
				# Assuming we are measuring in seconds, this tells us "Based on my current data, I am %confident that the true mean is within ±current_margin_of_error seconds of my measured mean." In other words, increasing the number of samples will make the margin of error smaller for the same confidence level. Given that we are asked to be at least some confidence level, we can calculate whether this is true or not yet (i.e. whether we need to keep sampling).
				#
				# The only caveat to this, is that we need to have at least @minimum samples before we can make this determination. If we have less than @minimum samples, we will return false. The reason for this is that we need a minimum number of samples to calculate a meaningful standard error and margin of error.
				# @returns [Boolean] true if the sample size has converged, false otherwise.
				def converged?
					return false if @count < @minimum
					# Calculate the current mean and standard error
					mean = self.mean
					standard_error = self.standard_error
					if mean && standard_error
						# Calculate the margin of error:
						current_margin_of_error = @z_score * standard_error
						# Normalize the margin of error relative to the mean:
						relative_margin_of_error = @margin_of_error * mean.abs
						# Check if the margin of error is within the acceptable range:
						current_margin_of_error <= relative_margin_of_error
					end
				end
			end
		end
	end
end
