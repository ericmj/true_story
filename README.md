# TrueStory

_Make your tests tell a story._

## Quick Start

To use TrueStory, just add as a dependency and write your tests. 

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `true_story` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:true_story, "~> 0.0.1"}]
    end
    ```

  2. Ensure `true_story` is started before your application:

    ```elixir
    def application do
      [applications: [:true_story]]
    end
    ```

## Writing Tests

First, you'll use `ExUnit.Case`, and import `TrueStory`, like this: 


```elixir
defmodule MyTest do
  use ExUnit.Case
  import TrueStory
  
  # tests go here
  
end
```
Next, you'll write your tests. Everything will compose, with each part of a story modifying a map, or context. To keep things brief, it's idiomatic to call the context `c`. 

### Experiments and Measurements

A TrueStory test has an experiment and measurements. The experiment changes the world, and the measurements evaluate the impact of the experiment. Experiments go in a `story` block and measurements go in a `verify` block. 

This story tests adding to a map. In the `story` block, you'll test 

```elixir
  story "adding to a map", c
    |> Map.put(:key, :value), 
  verify do
    assert c.key == :value
    refute c.key == :not_value
  end
```

### Building Your Story

You can write composable functions that transform a test context to build up your experiments, piece by piece, like this: 

```elixir

  defp add_to_map(c, key, value),
    do: Map.put(c, key, value)

  story "adding to a map", c
    |> add_to_map(:key, :value),
  verify do
    assert c.key == :value
    refute c.key == :not_value
  end

  story "overwriting a key", c
    |> add_to_map(:key, :old),
    |> add_to_map(:key, :new),
  verify do
    assert c.key == :new
    refute c.key == :old
  end

```

Most application tests are built in the setup. Piping together setup functions like this, you can build a growing library of setup functions for your application, and save your setup library in a common module. 

### Tests that Span Multiple Experiments

Maybe we would like to measure intermediate steps. To do so, you can run an integration test across tests, like this: 

```elixir

integrate "adding multiple keys" do
  story "adding to a map", c
    |> add_to_map(:key, :old),
  verify do
    assert c.key == :old
  end

  story "overwriting a key", c
    |> add_to_map(:key, :new),
  verify do
    assert c.key == :new
  end

  story "overwriting a key", c
    |> remove_from_map(:key),
  verify do
    refute c.key
  end
end
```

Like the experiment steps, these stories compose, with the previous story piped into the next. 

## Philosophies

- *Tests are first class citizens.* We'll use macros where needed to simplify tasks we do every day, to save repetition and ceremony. 
- *One experiment, multiple measurements.* That means every piece of test code has a distinct purpose. 
- *Experiments can be stateful; measurements can't.* This means that we can run each setup *once* so better performance is possible. 
- *Experiments raise; measurements return fail data.* This means we can return multiple failures per test, shorting cycle times. 
- *Everything composes.* We find that most testing effort is in setup. If setup is simple, the rest of the testing is much easier. 

Enjoy. Let us know what you think. 
