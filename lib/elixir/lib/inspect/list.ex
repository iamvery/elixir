defmodule Inspect.List do
  import Inspect.Algebra

  def inspect([], _opts), do: "[]"

  # TODO: Deprecate :char_lists and :as_char_lists keys in v1.5
  def inspect(term, %Inspect.Opts{charlists: lists, char_lists: lists_deprecated} = opts) do
    lists =
      if lists == :infer and lists_deprecated != :infer do
        case lists_deprecated do
          :as_char_lists ->
            :as_charlists
          _ ->
            lists_deprecated
        end
      else
        lists
      end

    cond do
      lists == :as_charlists or (lists == :infer and printable?(term)) ->
        <<?', Inspect.BitString.escape(IO.chardata_to_string(term), ?')::binary, ?'>>
      keyword?(term) ->
        surround_many("[", term, "]", opts, &keyword/2)
      true ->
        surround_many("[", term, "]", opts, &to_doc/2)
    end
  end

  @doc false
  def keyword({key, value}, opts) do
    concat(
      key_to_binary(key) <> ": ",
      to_doc(value, opts)
    )
  end

  @doc false
  def keyword?([{key, _value} | rest]) when is_atom(key) do
    case Atom.to_charlist(key) do
      'Elixir.' ++ _ -> false
      _ -> keyword?(rest)
    end
  end

  def keyword?([]),     do: true
  def keyword?(_other), do: false

  @doc false
  def printable?([c | cs]) when c in 32..126, do: printable?(cs)
  def printable?([?\n | cs]), do: printable?(cs)
  def printable?([?\r | cs]), do: printable?(cs)
  def printable?([?\t | cs]), do: printable?(cs)
  def printable?([?\v | cs]), do: printable?(cs)
  def printable?([?\b | cs]), do: printable?(cs)
  def printable?([?\f | cs]), do: printable?(cs)
  def printable?([?\e | cs]), do: printable?(cs)
  def printable?([?\a | cs]), do: printable?(cs)
  def printable?([]), do: true
  def printable?(_), do: false

  ## Private

  defp key_to_binary(key) do
    case Inspect.Atom.inspect(key) do
      ":" <> right -> right
      other -> other
    end
  end
end
