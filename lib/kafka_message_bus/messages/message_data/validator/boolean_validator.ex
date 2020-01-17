defmodule KafkaMessageBus.Messages.MessageData.Validator.BooleanValidator do
  @moduledoc """
  Provides checks for boolean fields.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  alias KafkaMessageBus.Messages.MessageData.MapUtil
  alias KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator

  def is_boolean(message_data, field_name, :not_required),
    do: is_boolean(message_data, field_name)

  def is_boolean(message_data, field_name, :required) do
    RequiredValidator.required(message_data, field_name, fn message_data, field_name ->
      is_boolean(message_data, field_name)
    end)
  end

  defp is_boolean(message_data, field_name) do
    value = MapUtil.safe_get(message_data, field_name)

    case value do
      value when is_boolean(value) ->
        ok()

      value when is_nil(value) ->
        ok(field_name, false)

      value when is_binary(value) ->
        parse_boolean(value, field_name, message_data)

      invalid_valid ->
        {:error, {:not_boolean, field_name, invalid_valid}}
    end
  end

  defp parse_boolean(value, field_name, message_data) when is_binary(value) do
    case String.downcase(value) do
      parsed_val when parsed_val == "true" or parsed_val == "false" ->
        ok(field_name, parsed_val == "true")

      _ ->
        {:error, {:not_a_boolean, field_name, MapUtil.safe_get(message_data, field_name)}}
    end
  end
end
