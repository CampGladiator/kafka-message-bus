defmodule KafkaMessageBus.Messages.MessageData.MapUtil do
  @moduledoc """
  A set of map utility functions utilized by the message validation.
  """
  require Logger

  def deep_to_struct(nil, %{} = _message_data), do: {:ok, nil}
  def deep_to_struct(struct, nil), do: {:ok, struct}

  @doc """
  This function is used to facilitate the definition of message data
  type's new/1 (factory) functions.
  """
  def deep_to_struct(struct, %{} = message_data) do
    mapped =
      Enum.reduce(Map.to_list(struct), struct, fn {key, _}, acc ->
        case __MODULE__.safe_get(message_data, key) do
          _value when key in [:__meta__, :__struct__] ->
            acc

          %{__struct__: Ecto.Association.NotLoaded} ->
            %{acc | key => nil}

          %{__struct__: struct_type} = value
          when struct_type in [DateTime, Time, Date, NaiveDateTime] ->
            %{acc | key => value}

          value when is_map(value) === true ->
            {:ok, struct_value} =
              Map.get(struct, key)
              |> deep_to_struct(value)

            %{acc | key => struct_value}

          value ->
            %{acc | key => value}
        end
      end)

    {:ok, mapped}
  end

  @doc """
  This function is used to convert the struct definition of message data
  to a map which is needed for changeset validation.
  """
  def deep_from_struct(%{__struct__: _} = struct) do
    struct
    |> Map.from_struct()
    |> Map.to_list()
    |> Enum.reduce(Map.from_struct(struct), fn {key, value}, acc ->
      case value do
        value when is_map(value) === true ->
          %{acc | key => Map.from_struct(value)}

        value ->
          %{acc | key => value}
      end
    end)
  end

  def deep_from_struct(struct) when is_map(struct), do: struct
  def deep_from_struct(nil), do: nil

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
      err_msg =
        "Failed to convert field_name '#{field_name}' to an existing atom. ERR: #{inspect(e)}"

      Logger.warn(fn -> err_msg end)
      {:error, err_msg}
  end

  defp string_to_atom(value, _map, _field_name), do: value
end
