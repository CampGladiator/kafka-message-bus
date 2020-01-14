defmodule KafkaMessageBus.Messages.MessageData.Validator.StringValidator do
  @moduledoc """
  Provides checks for string fields.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  alias KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator
  alias KafkaMessageBus.Utils

  def is_string(message_data, field_name, is_required, valid_values \\ [])
      when is_atom(is_required) and is_list(valid_values),
      do: do_is_string(message_data, field_name, is_required, valid_values)

  defp do_is_string(message_data, field_name, :not_required, valid_values),
    do: do_is_string(message_data, field_name, valid_values)

  defp do_is_string(message_data, field_name, :required, valid_values) do
    RequiredValidator.required(message_data, field_name, fn message_data, field_name ->
      do_is_string(message_data, field_name, valid_values)
    end)
  end

  defp do_is_string(message_data, field_name, valid_values) when is_list(valid_values) do
    value = Utils.safe_get(message_data, field_name)

    if is_nil(value) or String.valid?(value) do
      if has_valid_value(value, valid_values),
        do: ok(),
        else: {:error, {:invalid_field_value, field_name, value}}
    else
      {:error, {:not_a_string, field_name, value}}
    end
  end

  defp has_valid_value(nil, _), do: true
  defp has_valid_value(_value, []), do: true
  defp has_valid_value(value, valid_values), do: value in valid_values
end
