# TrueStory

_Make your tests tell a story._

## Why?

We've observed that well-written code and a well-structured API tells a good story. Writing single-purpose functions and improving setup composition improves tests. This thin DSL around ExUnit does exactly that.

## Quick Start

To use TrueStory, just add as a dependency and write your tests.

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

### Add Your Dependencies

Add `true_story` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:true_story, "~> 0.0.1", only: :test}]
    end
    ```

### Write Tests

First, you'll use `ExUnit.Case`, and also use `TrueStory`, like this:


```elixir
defmodule MyTest do
  use ExUnit.Case
  use TrueStory

  # tests go here

end
```
Next, you'll write your tests. Everything will compose, with each part of a story modifying a map, or context. To keep things brief, it's idiomatic to call the context `c`.

### Experiments (`story`) and measurements (`verify`)

A TrueStory test has an experiment and measurements. The experiment changes the world, and the measurements evaluate the impact of the experiment. Experiments go in a `story` section and measurements go in a `verify` block.

This story tests adding to a map. In the `story` block, you'll test

```elixir
story "adding to a map", c
  |> Map.put(:key, :value),
verify do
  assert c.key == :value
  refute c.key == :not_value
end
```

Please note: *verify blocks can't be stateful, and they can't mutate the context!* Keeping verify blocks pure allows us to run all verifications for a single test at once.

That's it. The `story` section has a name and a context pipe. The context pipe is a macro that allows basic piping, but also has some goodies for convenience.

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

### Linking Multiple Stories

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
This test expands to a single ExUnit test, so there's no concern about compatibility.

Like the experiment steps, these stories compose, with the previous story piped into the next.

## Goodies for convenience

### The `story` pipe

The pipe operator in the `story` macro allows you to access any key in the context placed there by an earlier pipe segment. For example, say you had some setup functions:

```elixir
defp create_user(c),
  do: Map.put(c, :user, %User{ name: "Bubba" }

defp create_blog(c, user),
  do: Map.put(c, :blog, %Blog{ name: "Fishin'", user: user }

defp create_post(c, blog, options), do: Blog.create(blog, options)
```

In your story, you can access the context in earlier pipe segments, like this:

```elixir
story "Creating a post", c
  |> create_user
  |> create_blog(c.user)
  |> create_post(c.blog, post: post_options),
verify do
  ...
end
```

Notice we're free to specify c.user and c.blog, which otherwise would be out of bounds. We can also take advantage of the same behavior in our setup functions with `assigns`, like this:

```elixir
defp blog_with_post(user, title, post) do
  assign(
    user: user,
    blog:create_blog(c.user),
    post: create_post(c.blog, c.user) )
end
```
That macro makes composing this kind of data much cleaner.

### defplot

Often, you want to add a single key to a test context. To make things easier for the person reading the test, you would like to make the name of the function in the story block and the key in the context the same. `defplot` makes this easy. You can build a single line of a story, called a `plot`, like this:

```elixir
defplot user(name, email) do
  %User{ name: name || "Bubba", email: email || "gone@fishin.example.com" }
end
```

Note that you can one-line simpler functions as well:

```elixir
defplot user(name, email), do:%User{ name: name, email: email }
```

That expands to:

```elixir
def user(c, name, email) do
  Map.put c, :user, %User{ name: name, email: email }
end
```

Say you have a story block that looks like this:

```elixir
story "Emailing a user", c
  |> user,
  |> application_function_emailing_a_user
verify do
  assert c.user.email
end
```

Now, it's clear that the `user` plot in the story populates the `:user` key in the context. Your stories are easier to read, and your plot lines are easier to write. Win/win.

## Philosophies

- *Tests are first class citizens.* We'll use macros where needed to simplify tasks we do every day, to save repetition and ceremony.
- *One experiment, multiple measurements.* That means every piece of test code has a distinct purpose.
- *Experiments can be stateful; measurements can't.* This means that we can run each setup *once* so better performance is possible.
- *Experiments raise; measurements return fail data.* This means we can return multiple failures per test, shorting cycle times.
- *Everything composes.* We find that most testing effort is in setup. If setup is simple, the rest of the testing is much easier.

Enjoy. Let us know what you think.
