defmodule TrueStoryTest do
  use ExUnit.Case
  use TrueStory

  defp add_to_map(c, key, value),
    do: Map.put(c, key, value)

  story "adding to a map", c
    |> add_to_map(:key, :value),
  verify do
    assert c.key == :value
    refute c.key == :not_value
  end

  # story "single multi error", c
  #   |> add_to_map(:key, :value),
  # verify do
  #   refute c.key == :value
  #   refute c.key == :not_value
  # end

  # story "two multi errors", c
  #   |> add_to_map(:key, :value),
  # verify do
  #   refute c.key == :value
  #   assert c.key == :not_value
  # end

  # story "multi error with failure", c
  #   |> add_to_map(:key, :value),
  # verify do
  #   refute c.key == :value
  #   assert c.key == :not_value
  #   raise "exception"
  # end
end
