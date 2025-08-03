# Sus::Fixtures::Benchmark

Provides fixtures for sus for running benchmarks.

[![Development Status](https://github.com/socketry/sus-fixtures-benchmark/workflows/Test/badge.svg)](https://github.com/socketry/sus-fixtures-benchmark/actions?workflow=Test)

## Installation

``` bash
bundle add sus-fixtures-benchmark
```

## Usage

Please see the [project documentation](https://socketry.github.io/sus-fixtures-benchmark/) for more details.

## Releases

Please see the [project releases](https://socketry.github.io/sus-fixtures-benchmark/releases/index) for all releases.

### v0.2.1

  - Fix links and add context.

### v0.2.0

  - Added `exactly(count)` method to `Sus::Fixtures::Benchmark::Repeats` which returns an `Exactly` instance for fixed-count benchmarking.

### v0.1.0

  - Added `Sus::Fixtures::Benchmark::Repeats` which is not an integer, but an instance that allows the block to be executed multiple times until the benchmark converges.

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
