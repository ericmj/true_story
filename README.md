# TrueStory

_Make your tests tell a story._

## Installation

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

## Using

```elixir
defmodule MyTest do
  use ExUnit.Case
  import TrueStory

  defp add_to_map(c, key, value),
    do: Map.put(c, key, value)

  story "adding to a map", c
    |> add_to_map(:key, :value),
  verify do
    assert c.key == :value
    refute c.key == :not_value
  end
end
```
