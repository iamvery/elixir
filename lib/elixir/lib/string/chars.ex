import Kernel, except: [to_string: 1]

defmodule String.Chars do
  @moduledoc ~S"""
  The `String.Chars` protocol is responsible for
  converting a structure to a Binary (only if applicable).
  The only function required to be implemented is
  `to_string` which does the conversion.

  The `to_string` function automatically imported
  by `Kernel` invokes this protocol. String
  interpolation also invokes `to_string` in its
  arguments. For example, `"foo#{bar}"` is the same
  as `"foo" <> to_string(bar)`.
  """

  @callback to_string(term) :: String.t

  def to_string(%{__struct__: module} = struct) do
    module.to_string(struct)
  end

  def to_string(nil), do: ""
  def to_string(atom) when is_atom(atom), do: Atom.to_string(atom)
  def to_string(term) when is_binary(term), do: term
  def to_string(charlist) when is_list(charlist), do: List.to_string(charlist)
  def to_string(term) when is_integer(term), do: Integer.to_string(term)

  def to_string(term) when is_float(term) do
    IO.iodata_to_binary(:io_lib_format.fwrite_g(term))
  end

  def to_string(term) when is_bitstring(term) do
    raise Protocol.UndefinedError,
             protocol: __MODULE__,
                value: term,
          description: "cannot convert a bitstring to a string"
  end

  def to_string(term) do
    raise Protocol.UndefinedError,
             protocol: __MODULE__,
                value: term
  end
end
