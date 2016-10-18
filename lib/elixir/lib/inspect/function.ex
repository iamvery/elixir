defmodule Inspect.Function do
  def inspect(function, _opts) do
    fun_info = :erlang.fun_info(function)
    mod = fun_info[:module]

    if fun_info[:type] == :external and fun_info[:env] == [] do
      "&#{Inspect.Atom.inspect(mod)}.#{fun_info[:name]}/#{fun_info[:arity]}"
    else
      case Atom.to_charlist(mod) do
        'elixir_compiler_' ++ _ ->
          if function_exported?(mod, :__RELATIVE__, 0) do
            "#Function<#{uniq(fun_info)} in file:#{mod.__RELATIVE__}>"
          else
            default_inspect(mod, fun_info)
          end
        _ ->
          default_inspect(mod, fun_info)
      end
    end
  end

  defp default_inspect(mod, fun_info) do
    "#Function<#{uniq(fun_info)}/#{fun_info[:arity]} in " <>
      "#{Inspect.Atom.inspect(mod)}#{extract_name(fun_info[:name])}>"
  end

  defp extract_name([]) do
    ""
  end

  defp extract_name(name) do
    name = Atom.to_string(name)
    case :binary.split(name, "-", [:global]) do
      ["", name | _] -> "." <> name
      _ -> "." <> name
    end
  end

  defp uniq(fun_info) do
    Integer.to_string(fun_info[:new_index]) <> "." <>
      Integer.to_string(fun_info[:uniq])
  end
end
