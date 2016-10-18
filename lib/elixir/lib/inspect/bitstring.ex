defmodule Inspect.BitString do
  import Inspect.Algebra

  def inspect(term, %Inspect.Opts{binaries: bins, base: base} = opts) when is_binary(term) do
    if base == :decimal and (bins == :as_strings or (bins == :infer and String.printable?(term))) do
      <<?", escape(term, ?")::binary, ?">>
    else
      inspect_bitstring(term, opts)
    end
  end

  def inspect(term, opts) do
    inspect_bitstring(term, opts)
  end

  ## Escaping

  @doc false
  def escape(other, char) do
    escape(other, char, <<>>)
  end

  defp escape(<<char, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, char>>)
  end
  defp escape(<<?#, ?{, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?#, ?{>>)
  end
  defp escape(<<?\a, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?a>>)
  end
  defp escape(<<?\b, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?b>>)
  end
  defp escape(<<?\d, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?d>>)
  end
  defp escape(<<?\e, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?e>>)
  end
  defp escape(<<?\f, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?f>>)
  end
  defp escape(<<?\n, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?n>>)
  end
  defp escape(<<?\r, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?r>>)
  end
  defp escape(<<?\\, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?\\>>)
  end
  defp escape(<<?\t, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?t>>)
  end
  defp escape(<<?\v, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, ?\\, ?v>>)
  end
  defp escape(<<h::utf8, t::binary>>, char, binary) do
    head = <<h::utf8>>
    if String.printable?(head) do
      escape(t, char, append(head, binary))
    else
      <<byte::8, h::binary>> = head
      t = <<h::binary, t::binary>>
      escape(t, char, <<binary::binary, escape_char(byte)::binary>>)
    end
  end
  defp escape(<<h, t::binary>>, char, binary) do
    escape(t, char, <<binary::binary, escape_char(h)::binary>>)
  end
  defp escape(<<>>, _char, binary), do: binary

  @doc false
  # Also used by Regex
  def escape_char(0) do
    <<?\\, ?0>>
  end

  def escape_char(char) when char < 0x100 do
    <<a::4, b::4>> = <<char::8>>
    <<?\\, ?x, to_hex(a), to_hex(b)>>
  end

  def escape_char(char) when char < 0x10000 do
    <<a::4, b::4, c::4, d::4>> = <<char::16>>
    <<?\\, ?x, ?{, to_hex(a), to_hex(b), to_hex(c), to_hex(d), ?}>>
  end

  def escape_char(char) when char < 0x1000000 do
    <<a::4, b::4, c::4, d::4, e::4, f::4>> = <<char::24>>
    <<?\\, ?x, ?{, to_hex(a), to_hex(b), to_hex(c),
                   to_hex(d), to_hex(e), to_hex(f), ?}>>
  end

  defp to_hex(c) when c in 0..9, do: ?0+c
  defp to_hex(c) when c in 10..15, do: ?A+c-10

  defp append(<<h, t::binary>>, binary), do: append(t, <<binary::binary, h>>)
  defp append(<<>>, binary), do: binary

  ## Bitstrings

  defp inspect_bitstring("", _opts) do
    "<<>>"
  end

  defp inspect_bitstring(bitstring, opts) do
    nest surround("<<", each_bit(bitstring, opts.limit, opts), ">>"), 1
  end

  defp each_bit(_, 0, _) do
    "..."
  end

  defp each_bit(<<>>, _counter, _opts) do
    :doc_nil
  end

  defp each_bit(<<h::8>>, _counter, opts) do
    Inspect.Integer.inspect(h, opts)
  end

  defp each_bit(<<h, t::bitstring>>, counter, opts) do
    glue(concat(Inspect.Integer.inspect(h, opts), ","),
         each_bit(t, decrement(counter), opts))
  end

  defp each_bit(bitstring, _counter, opts) do
    size = bit_size(bitstring)
    <<h::size(size)>> = bitstring
    Inspect.Integer.inspect(h, opts) <> "::size(" <> Integer.to_string(size) <> ")"
  end

  defp decrement(:infinity), do: :infinity
  defp decrement(counter),   do: counter - 1
end
