# frozen_string_literal: true

require_relative "lib/sus/fixtures/benchmark/version"

Gem::Specification.new do |spec|
	spec.name = "sus-fixtures-benchmark"
	spec.version = Sus::Fixtures::Benchmark::VERSION
	
	spec.summary = "Test fixtures for benchmarking."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/suspecting/sus-fixtures-benchmark"
	
	spec.metadata = {
		"documentation_uri" => "https://suspecting.github.io/sus-fixtures-benchmark/",
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/suspecting/sus-fixtures-benchmark.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "sus", "~> 0.31"
	spec.add_dependency "distribution", "~> 0.8"
	spec.add_dependency "prime"
end
