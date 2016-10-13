defmodule List.Chars do
  @moduledoc ~S"""
  The List.Chars protocol is responsible for
  converting a structure to a list (only if applicable).
  The only function required to be implemented is
  `to_charlist` which does the conversion.

  The `to_charlist` function automatically imported
  by `Kernel` invokes this protocol.
  """

  @callback to_charlist(term) :: []

  def to_charlist(%{__struct__: module} = struct) do
    module.to_charlist(struct)
  end

  def to_charlist(atom) when is_atom(atom), do: Atom.to_charlist(atom)
  # Note that same inlining is used for the rewrite rule.
  def to_charlist(list) when is_list(list), do: list

  def to_charlist(term) when is_integer(term) do
    Integer.to_charlist(term)
  end

  def to_charlist(term) when is_float(term) do
    :io_lib_format.fwrite_g(term)
  end

  def to_charlist(term) when is_binary(term) do
    String.to_charlist(term)
  end

  def to_charlist(term) do
    raise Protocol.UndefinedError,
             protocol: __MODULE__,
                value: term,
          description: "cannot convert a bitstring to a charlist"
  end

  # TODO: Deprecate by v1.5
  @doc false
  Kernel.def to_char_list(term) do
    __MODULE__.to_charlist(term)
  end
end
