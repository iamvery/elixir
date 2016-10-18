defmodule Inspect.Integer do
  def inspect(term, %Inspect.Opts{base: base}) do
    Integer.to_string(term, base_to_value(base))
    |> prepend_prefix(base)
  end

  defp base_to_value(base) do
    case base do
      :binary  -> 2
      :decimal -> 10
      :octal   -> 8
      :hex     -> 16
    end
  end

  defp prepend_prefix(value, :decimal), do: value
  defp prepend_prefix(value, base) do
    prefix = case base do
      :binary -> "0b"
      :octal  -> "0o"
      :hex    -> "0x"
    end
    prefix <> value
  end
end
