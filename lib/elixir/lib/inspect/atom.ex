defmodule Inspect.Atom do
  require Macro

  def inspect(false),  do: "false"
  def inspect(true),   do: "true"
  def inspect(nil),    do: "nil"
  def inspect(:""),    do: ":\"\""

  def inspect(atom) do
    binary = Atom.to_string(atom)

    cond do
      valid_ref_identifier?(binary) ->
        if only_elixir?(binary) do
          binary
        else
          "Elixir." <> rest = binary
          rest
        end
      valid_atom_identifier?(binary) ->
        ":" <> binary
      atom in [:%{}, :{}, :<<>>, :..., :%] ->
        ":" <> binary
      atom in Macro.binary_ops or atom in Macro.unary_ops ->
        ":" <> binary
      true ->
        <<?:, ?", Inspect.BitString.escape(binary, ?")::binary, ?">>
    end
  end

  defp only_elixir?("Elixir." <> rest), do: only_elixir?(rest)
  defp only_elixir?("Elixir"), do: true
  defp only_elixir?(_), do: false

  # Detect if atom is an atom alias (Elixir.Foo.Bar.Baz)

  defp valid_ref_identifier?("Elixir" <> rest) do
    valid_ref_piece?(rest)
  end

  defp valid_ref_identifier?(_), do: false

  defp valid_ref_piece?(<<?., h, t::binary>>) when h in ?A..?Z do
    valid_ref_piece? valid_identifier?(t)
  end

  defp valid_ref_piece?(<<>>), do: true
  defp valid_ref_piece?(_),    do: false

  # Detect if atom

  defp valid_atom_identifier?(<<h, t::binary>>) when h in ?a..?z or h in ?A..?Z or h == ?_ do
    valid_atom_piece?(t)
  end

  defp valid_atom_identifier?(_), do: false

  defp valid_atom_piece?(t) do
    case valid_identifier?(t) do
      <<>>              -> true
      <<??>>            -> true
      <<?!>>            -> true
      <<?@, t::binary>> -> valid_atom_piece?(t)
      _                 -> false
    end
  end

  defp valid_identifier?(<<h, t::binary>>)
      when h in ?a..?z
      when h in ?A..?Z
      when h in ?0..?9
      when h == ?_ do
    valid_identifier? t
  end

  defp valid_identifier?(other), do: other
end
