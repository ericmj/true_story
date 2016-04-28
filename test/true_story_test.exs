defmodule TrueStoryTest do
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
