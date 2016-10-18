defmodule Inspect.Map do
  import Inspect.Algebra

  def inspect(map, opts) do
    nest inspect(map, "", opts), 1
  end

  def inspect(map, name, opts) do
    map = :maps.to_list(map)
    surround_many("%" <> name <> "{", map, "}", opts, traverse_fun(map))
  end

  defp traverse_fun(list) do
    if Inspect.List.keyword?(list) do
      &Inspect.List.keyword/2
    else
      &to_map/2
    end
  end

  defp to_map({key, value}, opts) do
    concat(
      concat(to_doc(key, opts), " => "),
      to_doc(value, opts)
    )
  end
end
