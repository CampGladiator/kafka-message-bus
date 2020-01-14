defmodule KafkaMessageBus.Messages.MessageData.Validator.FloatValidator do
  @moduledoc """
  Provides checks for float fields.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  alias KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator
  alias KafkaMessageBus.Utils

  def is_float(message_data, field_name, :not_required),
    do: is_float(message_data, field_name)

  def is_float(message_data, field_name, :required) do
    RequiredValidator.required(message_data, field_name, fn message_data, field_name ->
      is_float(message_data, field_name)
    end)
  end

  defp is_float(message_data, field_name) do
    value = Utils.safe_get(message_data, field_name)

    case value do
      value when is_float(value) ->
        ok()

      value when is_nil(value) ->
        ok(field_name, 0)

      value when is_integer(value) ->
        ok(field_name, value / 1)

      value when is_binary(value) ->
        parse_float(value, field_name, message_data)

      _ ->
        {:error, {:not_a_float, field_name, Utils.safe_get(message_data, field_name)}}
    end
  end

  defp parse_float(value, field_name, message_data) do
    case Float.parse(value) do
      {parsed_val, ""} ->
        ok(field_name, parsed_val)

      _ ->
        {:error, {:not_a_float, field_name, Utils.safe_get(message_data, field_name)}}
    end
  end
end
