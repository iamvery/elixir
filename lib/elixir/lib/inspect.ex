import Kernel, except: [inspect: 1]
import Inspect.Algebra

defmodule Inspect do
  @moduledoc """
  The `Inspect` protocol is responsible for converting any Elixir
  data structure into an algebra document. This document is then
  formatted, either in pretty printing format or a regular one.

  The `inspect/2` function receives the entity to be inspected
  followed by the inspecting options, represented by the struct
  `Inspect.Opts`.

  Inspection is done using the functions available in `Inspect.Algebra`.

  ## Examples

  Many times, inspecting a structure can be implemented in function
  of existing entities. For example, here is `MapSet`'s `inspect`
  implementation:

      defimpl Inspect, for: MapSet do
        import Inspect.Algebra

        def inspect(dict, opts) do
          concat ["#MapSet<", to_doc(MapSet.to_list(dict), opts), ">"]
        end
      end

  The `concat` function comes from `Inspect.Algebra` and it
  concatenates algebra documents together. In the example above,
  it is concatenating the string `"MapSet<"` (all strings are
  valid algebra documents that keep their formatting when pretty
  printed), the document returned by `Inspect.Algebra.to_doc/2` and the
  other string `">"`.

  Since regular strings are valid entities in an algebra document,
  an implementation of inspect may simply return a string,
  although that will devoid it of any pretty-printing.

  ## Error handling

  In case there is an error while your structure is being inspected,
  Elixir will raise an `ArgumentError` error and will automatically fall back
  to a raw representation for printing the structure.

  You can however access the underlying error by invoking the Inspect
  implementation directly. For example, to test Inspect.MapSet above,
  you can invoke it as:

      Inspect.MapSet.inspect(MapSet.new, %Inspect.Opts{})

  """

  @callback inspect(term, Inspect.Opts.t) :: String.t

  # TODO move this to Regex module
  def inspect(%{__struct__: Regex} = struct, opts) do
    Inspect.Regex.inspect(struct, opts)
  end

  def inspect(%{__struct__: module} = struct, opts) do
    try do
      module.inspect(struct, opts)
    rescue
      UndefinedFunctionError -> Inspect.Struct.inspect(struct, opts)
    end
  end

  def inspect({}, _opts), do: "{}"
  def inspect(atom, _opts) when is_atom(atom), do: Inspect.Atom.inspect(atom)
  def inspect(term, opts) when is_bitstring(term), do: Inspect.BitString.inspect(term, opts)
  def inspect(list, opts) when is_list(list), do: Inspect.List.inspect(list, opts)
  def inspect(map, opts) when is_map(map), do: Inspect.Map.inspect(map, opts)
  def inspect(int, opts) when is_integer(int), do: Inspect.Integer.inspect(int, opts)
  def inspect(fun, opts) when is_function(fun), do: Inspect.Function.inspect(fun, opts)

  def inspect(tuple, opts) when is_tuple(tuple) do
    surround_many("{", Tuple.to_list(tuple), "}", opts, &to_doc/2)
  end

  def inspect(term, _opts) when is_float(term) do
    IO.iodata_to_binary(:io_lib_format.fwrite_g(term))
  end

  def inspect(pid, _opts) when is_pid(pid) do
    "#PID" <> IO.iodata_to_binary(:erlang.pid_to_list(pid))
  end

  def inspect(port, _opts) when is_port(port) do
    IO.iodata_to_binary :erlang.port_to_list(port)
  end

  def inspect(ref, _opts) when is_reference(ref) do
    '#Ref' ++ rest = :erlang.ref_to_list(ref)
    "#Reference" <> IO.iodata_to_binary(rest)
  end
end
