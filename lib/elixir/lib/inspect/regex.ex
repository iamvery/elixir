defmodule Inspect.Regex do
  import Inspect.Algebra

  def inspect(regex, _opts) do
    delim = ?/
    concat ["~r",
            <<delim, escape(regex.source, delim)::binary, delim>>,
            regex.opts]
  end

  defp escape(bin, term),
    do: escape(bin, <<>>, term)

  defp escape(<<?\\, term>> <> rest, buf, term),
    do: escape(rest, buf <> <<?\\, term>>, term)

  defp escape(<<term>> <> rest, buf, term),
    do: escape(rest, buf <> <<?\\, term>>, term)

  # the list of characters is from "String.printable?" impl
  # minus characters treated specially by regex: \s, \d, \b, \e

  defp escape(<<?\n>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, ?\\, ?n>>, term)

  defp escape(<<?\r>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, ?\\, ?r>>, term)

  defp escape(<<?\t>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, ?\\, ?t>>, term)

  defp escape(<<?\v>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, ?\\, ?v>>, term)

  defp escape(<<?\f>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, ?\\, ?f>>, term)

  defp escape(<<?\a>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, ?\\, ?a>>, term)

  defp escape(<<c::utf8>> <> rest, buf, term) do
    charstr = <<c::utf8>>
    if String.printable?(charstr) and not c in [?\d, ?\b, ?\e] do
      escape(rest, buf <> charstr, term)
    else
      escape(rest, buf <> Inspect.BitString.escape_char(c), term)
    end
  end

  defp escape(<<c>> <> rest, buf, term),
    do: escape(rest, <<buf::binary, Inspect.BitString.escape_char(c)>>, term)

  defp escape(<<>>, buf, _), do: buf
end
