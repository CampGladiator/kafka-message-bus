defmodule KafkaMessageBus.Messages.MessageData.Validator.IntegerValidator do
  @moduledoc """
  Provides checks for integer fields.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  alias KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator
  alias KafkaMessageBus.Utils

  def is_integer(message_data, field_name, :not_required),
    do: is_integer(message_data, field_name)

  def is_integer(message_data, field_name, :required) do
    RequiredValidator.required(message_data, field_name, fn message_data, field_name ->
      is_integer(message_data, field_name)
    end)
  end

  defp is_integer(message_data, field_name) do
    case Utils.safe_get(message_data, field_name) do
      value when is_integer(value) ->
        ok()

      value when is_nil(value) ->
        ok(field_name, 0)

      value when is_float(value) ->
        value
        |> Float.to_string()
        |> parse_integer(field_name, message_data)

      value when is_binary(value) ->
        parse_integer(value, field_name, message_data)

      _ ->
        {:error, {:not_an_integer, field_name, Utils.safe_get(message_data, field_name)}}
    end
  end

  defp parse_integer(value, field_name, message_data) do
    case Integer.parse(value) do
      {int_val, remainder} when remainder == "" or remainder == ".0" ->
        ok(field_name, int_val)

      _ ->
        {:error, {:not_an_integer, field_name, Utils.safe_get(message_data, field_name)}}
    end
  end
end
