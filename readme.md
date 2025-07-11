# Sus::Fixtures::Benchmark

Provides fixtures for sus for running benchmarks.

[![Development Status](https://github.com/socketry/sus-fixtures-benchmark/workflows/Test/badge.svg)](https://github.com/socketry/sus-fixtures-benchmark/actions?workflow=Test)

## Installation

``` bash
bundle add sus-fixtures-benchmark
```

## Usage

``` ruby
require "sus/fixtures/benchmark"

include Sus::Fixtures::Benchmark

measure "my benchmark" do |repeats|
	# code to benchmark
	repeats.times{sleep 0.001}
end
```

Note that `repeats` is not an integer, but an instance of `Sus::Fixtures::Benchmark::Repeats`. The block will be executed multiple times until the benchmark converges, meaning that the results are stable enough to be considered reliable.

## Releases

There are no documented releases.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
