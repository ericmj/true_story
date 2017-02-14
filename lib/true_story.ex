defmodule TrueStory do

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__), only: [story: 2, story: 4, assign: 2, integration: 2]
      import ExUnit.Assertions, except: [assert: 1, assert: 2, refute: 1, refute: 2]
      import TrueStory.Assertions
      @true_story_integration false
    end
  end

  defmacro integration(name, block) do
    context_var = quote do
      context
    end
    Module.put_attribute __CALLER__.module, :true_story_integration,  true
    Module.put_attribute __CALLER__.module, :true_story_functions,  []
    Module.put_attribute __CALLER__.module, :integration_test_name, name

    # NOTE: This is a hack!
    Module.eval_quoted(__CALLER__.module, block, [], __CALLER__)

    Module.put_attribute __CALLER__.module, :true_story_integration,  false

    quote do
      test unquote(name), unquote(context_var) do
        unquote(build_integration_test(context_var, __CALLER__.module))
      end
    end
  end

  def build_integration_test(context, module) do
    functions = Module.get_attribute(module, :true_story_functions) |> Enum.reverse
    Enum.reduce(functions, context, fn(name, ast) ->
      quote do
        unquote(ast) |> unquote(name)()
      end
    end)
  end

  defmacro story(name, block) do
    quote do
      story(unquote(name), _c, verify, unquote(block))
    end
  end

  defmacro story(name, setup, verify, block) do
    inside_integration_block = Module.get_attribute __CALLER__.module, :true_story_integration
    _story(inside_integration_block, name, setup, verify, block, __CALLER__.module)
  end

  defp _story(true, name, setup, verify, block, integration_test_module) do
    [{context_var, 0} | pipes] = Macro.unpipe(setup)
    setup = expand_setup(context_var, pipes)
    _verify = expand_verify(verify)
    block = expand_block(block)


    test_function_name = create_name name, integration_test_module
    existing_functions = Module.get_attribute(integration_test_module, :true_story_functions)
    Module.put_attribute integration_test_module, :true_story_functions, [test_function_name|existing_functions]

    quote do
      def unquote(test_function_name)( context ) do
        try do
          TrueStory.setup_pdict()
          unquote(setup)
          unquote(block)
          unquote(context_var)
        catch
          kind, error ->
            TrueStory.raise_multi([{kind, error, System.stacktrace}])
        else
          context ->
            TrueStory.raise_multi([])
            context
        end
      end
    end
  end

  defp _story(integrated, name, setup, verify, block, _) when integrated in [nil, false] do
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

  # TODO capture pretty error. This fails if there are two integration tests of the same name
  def create_name(text, integration_test_module) do
    String.to_atom("#{Module.get_attribute(integration_test_module, :integration_test_name)} #{text}")
  end

  defp expand_setup(context_var, pipes) do
    acc = quote do: unquote(context_var) = context

    Enum.reduce(pipes, acc, fn {call, 0}, acc ->
      quote do
        unquote(acc)
        unquote(context_var) = unquote(context_var) |> unquote(call)
      end
    end)
  end

  defp expand_verify({:verify, _, context}) when is_atom(context), do: nil

  defp expand_block([do: block]), do: block

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

  defmacro assign(context, assigns) do
    ast = quote do: context = unquote(context)
    Enum.reduce(assigns, ast, fn {key, expr}, ast ->
      expr = Macro.prewalk(expr, &translate_var(&1, context))
      quote do
        unquote(ast)
        context = Map.put(context, unquote(key), unquote(expr))
      end
    end)
  end

  defp translate_var({name, _, context}, {name, _, context}) do
    quote do: context
  end
  defp translate_var(expr, _context) do
    expr
  end
end
