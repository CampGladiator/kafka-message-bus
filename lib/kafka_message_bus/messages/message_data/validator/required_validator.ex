defmodule KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator do
  @moduledoc """
  Provides checks for required fields.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  alias KafkaMessageBus.Utils

  def required(message_data, fields) when is_list(fields) do
    if Enum.any?(fields) do
      if contains_fields?(message_data, fields) do
        ok()
      else
        if Enum.count(fields) == 1,
          do: {:error, {:field_required, Enum.at(fields, 0), nil}},
          else: {:error, {:field_required, fields, nil}}
      end
    else
      {:error, :field_missing}
    end
  end

  def required(message_data, field_name), do: required(message_data, [field_name])

  def required(message_data, field_name, ok_function) when is_function(ok_function) do
    case required(message_data, field_name) do
      {:ok, _} ->
        ok_function.(message_data, field_name)

      err ->
        err
    end
  end

  defp contains_fields?(message_data, fields) when is_map(message_data) do
    Enum.reduce(fields, false, fn field, acc ->
      acc or not (message_data |> Utils.safe_get(field) |> is_nil)
    end)
  end

  defp contains_fields?(message_data, _),
    do: {:error, "Expected a map for message_data but got: #{inspect(message_data)}"}
end
