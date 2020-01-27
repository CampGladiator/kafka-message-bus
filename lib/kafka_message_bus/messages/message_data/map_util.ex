defmodule KafkaMessageBus.Messages.MessageData.MapUtil do
  @moduledoc """
  A set of map utility functions utilized by the message validation.
  """
  require Logger

  @doc """
  Will attempt to retrieve from a map using an atom as the key. If no value is found,
  the function will attempt again after converting the atom to a string.
  """
  def safe_get(map, field_name) when is_map(map) and is_atom(field_name),
    do:
      map
      |> Map.get(field_name)
      |> atom_to_string(map, field_name)

  @doc """
  Will attempt to retrieve from a map using a string as the key. If no value is found,
  the function will attempt again after converting the string to an atom.
  """
  def safe_get(map, field_name) when is_map(map) and is_binary(field_name),
    do:
      map
      |> Map.get(field_name)
      |> string_to_atom(map, field_name)

  @doc """
  Default function returns an error.
  """
  def safe_get(map, field_name),
    do:
      {:error,
       "Unexpected param encountered. map: #{inspect(map)}, field_name: #{inspect(field_name)}"}

  defp atom_to_string(nil, map, field_name), do: Map.get(map, Atom.to_string(field_name))
  defp atom_to_string(value, _map, _field_name), do: value

  defp string_to_atom(nil, map, field_name) do
    Map.get(map, String.to_existing_atom(field_name))
  rescue
    e ->
      Logger.warn(fn ->
        "Failed to convert field_name '#{field_name}' to an existing atom. ERR: #{inspect(e)}"
      end)
  end

  defp string_to_atom(value, _map, _field_name), do: value
end