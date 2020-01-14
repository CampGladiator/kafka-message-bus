defmodule KafkaMessageBus.Messages.MessageData.Validator.Response do
  @moduledoc """
  A small set of functions that provide a shortcut for creating response tuples.
  """

  @doc "
  Prepares :ok tuple that contains a map with the provided field_name and value for a change suggestion.
  "
  def ok(field_name, value), do: {:ok, Map.put(%{}, field_name, value)}
  @doc "
  Passes maps through.
  "
  def ok(data) when is_map(data), do: {:ok, data}
  @doc "
  Prepares :ok tuple that contains an empty map (no change suggestion)
  "
  def ok, do: {:ok, %{}}
end
