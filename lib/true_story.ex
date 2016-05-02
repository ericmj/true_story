defmodule TrueStory do

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [story: 4]
      import ExUnit.Assertions, except: [assert: 1, assert: 2, refute: 1, refute: 2]
      import TrueStory.Assertions
    end
  end

  defmacro story(name, setup, verify, block) do
    [{context_var, 0} | pipes] = Macro.unpipe(setup)
    setup = expand_setup(context_var, pipes)
    _verify = expand_verify(verify)
    block = expand_block(block)

    quote do
      test unquote(name), context do
        try do
          TrueStory.setup_pdict()
          unquote(setup)
          unquote(block)
        catch
          kind, error ->
            TrueStory.raise_multi([{kind, error, System.stacktrace}])
        else
          value ->
            TrueStory.raise_multi([])
            value
        end
      end
    end
  end

  defp expand_setup(context_var, pipes) do
    pipes = Enum.reverse(pipes)
    acc = quote do: unquote(context_var) = context

    Enum.reduce(pipes, acc, fn {call, 0}, acc ->
      quote do
        unquote(acc)
        unquote(context_var) = unquote(context_var) |> unquote(call)
      end
    end)
  end

  defp expand_verify({:verify, _, nil}), do: nil

  defp expand_block([do: block]), do: block

  # def assign(context, assigns) do
  #   Dict.merge(context, assigns)
  # end

  @doc false
  def setup_pdict do
    Process.put(:true_story_errors, [])
  end

  @doc false
  def raise_multi(failure) do
    errors = Enum.reverse(failure ++ Process.get(:true_story_errors))

    case errors do
      [] ->
        :ok
      [{kind, error, stack}] ->
        :erlang.raise(kind, error, stack)
      errors ->
        raise ExUnit.MultiError.exception(errors: errors)
    end
  end
end
