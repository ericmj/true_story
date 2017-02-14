defmodule TrueStoryTest do
  use ExUnit.Case
  use TrueStory

  defp add_to_map(c, key, value),
    do: Map.put(c, key, value)

  story "flat story" do
    assert :erlang.phash("", 1) == 1
  end

  story "adding to a map", c
    |> add_to_map(:key, :value),
  verify do
    assert c.key == :value
    refute c.key == :not_value
  end

  test "assign", c do
    c = assign c, key: :value
    assert c.key == :value

    _ = assign c, key: :value2
    refute c.key == :value2

    c = assign c,
      number1: 1,
      number2: c.number1+1

    assert c.number2 == 2
  end

  integration "adding and removing a key from a map" do
    story "adding to a map", c
      |> add_to_map(:key, :value),
    verify do
      # assert false
      assert c.key == :value
      refute c.key == :not_value
    end

    story "adding another key to the map", c
      |> add_to_map(:another_key, :value),
    verify do
      # assert false
      assert c.key == :value
      assert c.another_key == :value
      refute c.key == :not_value
    end
  end

  # FAILURES
  # story "single multi error", c
  #   |> add_to_map(:key, :value),
  # verify do
  #   refute c.key == :value
  #   refute c.key == :not_value
  # end
  #
  # story "two multi errors", c
  #   |> add_to_map(:key, :value),
  # verify do
  #   refute c.key == :value
  #   assert c.key == :not_value
  # end
  #
  # story "multi error with failure", c
  #   |> add_to_map(:key, :value),
  # verify do
  #   refute c.key == :value
  #   assert c.key == :not_value
  #   raise "exception"
  # end
end
