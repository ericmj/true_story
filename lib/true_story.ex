defmodule TrueStory do
  defmacro story(name, setup, verify, block) do
    [{context_var, 0} | pipes] = Macro.unpipe(setup)
    setup = expand_setup(context_var, pipes)
    _verify = expand_verify(verify)
    block = expand_block(block)

    quote do
      test unquote(name), context do
        unquote(setup)
        unquote(block)
      end
    end
  end

  def expand_setup(context_var, pipes) do
    pipes = Enum.reverse(pipes)
    acc = quote do: unquote(context_var) = context

    Enum.reduce(pipes, acc, fn {call, 0}, acc ->
      quote do
        unquote(acc)
        unquote(context_var) = unquote(context_var) |> unquote(call)
      end
    end)
  end

  def expand_verify({:verify, _, nil}), do: nil

  def expand_block([do: block]), do: block

  # def assign(context, assigns) do
  #   Dict.merge(context, assigns)
  # end
end
