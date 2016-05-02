defmodule TrueStory.Assertions do
  @doc false
  def __wrapper__(expr) do
    quote do
      try do
        unquote(expr)
      catch
        :error, %ExUnit.AssertionError{} = error ->
          stack = System.stacktrace
          if errors = Process.get(:true_story_errors) do
            Process.put(:true_story_errors, [{:error, error, stack}|errors])
          else
            :erlang.raise(:error, error, stack)
          end
      end
    end
  end

  @doc false
  defmacro __wrapper_macro__(expr) do
    __wrapper__(expr)
  end

  defmacro assert(assertion) do
    __wrapper__(quote do: ExUnit.Assertions.assert(unquote(assertion)))
  end

  defmacro refute(assertion) do
    __wrapper__(quote do: ExUnit.Assertions.refute(unquote(assertion)))
  end

  def assert(value, message) do
    TrueStory.Assertions.__wrapper__(ExUnit.Assertions.assert(value, message))
  end

  def refute(value, message) do
    TrueStory.Assertions.__wrapper__(ExUnit.Assertions.refute(value, message))
  end
end
