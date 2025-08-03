# Getting Started

This guide explains how to use the `sus-fixtures-benchmark` gem to measure and benchmark code performance within your Sus test suite.

## Quick Start

### Project Structure

We recommend organizing your benchmarks in a dedicated `benchmark/` directory:

```
your-project/
├── benchmark/
│   ├── database_performance.rb
│   ├── algorithm_comparison.rb
│   └── memory_usage.rb
├── test/
├── lib/
└── Gemfile
```

This keeps your benchmarks separate from your regular tests and makes them easy to find and run.

### Basic Measurement

The simplest way to measure code performance is using the `measure` method:

```ruby
# benchmark/array_performance.rb
require "sus/fixtures/benchmark"

describe "Array Performance" do
  include Sus::Fixtures::Benchmark
  
  let(:data) {(1..1000).to_a}
  
  measure "array iteration" do |repeats|
    repeats.times do
      data.each{|i| i * 2}
    end
  end
end
```

This will automatically run your code until statistical convergence is reached and report the results.

**Run with:** `sus --verbose benchmark/array_performance.rb`

### Understanding the Output

When you run your tests with `sus --verbose`, you'll see output like:

```
measure array iteration 34 samples, mean: 0.15ms, standard deviation: 0.02ms, standard error: 0.003ms
```

**Important:** You must run `sus --verbose` to see the benchmark output. Without the verbose flag, the benchmark results will not be displayed.

This tells you:
- **34 samples**: How many times the code was executed.
- **mean: 0.15ms**: Average execution time.
- **standard deviation: 0.02ms**: How much variation there was between runs.
- **standard error: 0.003ms**: How reliable the mean estimate is.

## Measurement Modes

### Automatic Convergence (Default)

By default, the benchmark runs until it achieves statistical convergence:

```ruby
measure "database query" do |repeats|
  repeats.times do
    User.where(active: true).count
  end
end
```

The system will automatically determine when it has enough samples to provide a reliable measurement based on:
- **Confidence level**: 95% by default
- **Margin of error**: 2% of the mean by default (0.02)
- **Minimum samples**: 8 by default

### Fixed Number of Iterations

If you need a specific number of iterations, use the `exactly` method:

```ruby
measure "quick test" do |repeats|
  repeats.exactly(10).times do
    # Your code here
  end
end
```

This is useful for:
- Quick smoke tests.
- When you know the exact number of iterations needed.
- Debugging or development scenarios.

## Configuration Options

### Customizing the Sampler

You can customize the statistical parameters directly in the `measure` method:

```ruby
measure "high precision", minimum: 20, confidence: 0.98, margin_of_error: 0.01 do |repeats|
  repeats.times do
    # Your code here
  end
end
```

### Parameter Reference

You should try to avoid deviating from the defaults.

  - **`minimum`** (Integer): Minimum samples before convergence (default: 8). 
    - **Lower `minimum`**: Quick development feedback (e.g., `minimum: 3`)
    - **Higher `minimum`**: High-variance operations (e.g., `minimum: 30`)
  - **`confidence`** (Float): Confidence level 0.0-1.0 (default: 0.95). High confidence (above 0.98) may take an extremely long time to converge.
    - **Lower `confidence`**: Faster results (e.g., `confidence: 0.90`)
    - **Higher `confidence`**: Production guarantees (e.g., `confidence: 0.98`)
  - **`margin_of_error`** (Float): Acceptable error as a fraction of the mean (default: 0.02 = 2%).
    - **Lower `margin_of_error`**: High precision (e.g., `margin_of_error: 0.01`)
    - **Higher `margin_of_error`**: Rough estimates (e.g., `margin_of_error: 0.05`)
