defmodule KafkaMessageBus.Messages.MessageData.Validator.DateTimeValidator do
  @moduledoc """
  Provides checks for datetime, date, and time fields.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  alias KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator
  alias KafkaMessageBus.Utils
  require Logger

  def is_valid_date_time_utc(message_data, field_name, required?),
    do: valid_utc(DateTime, message_data, field_name, required?)

  def is_valid_date_utc(message_data, field_name, required?),
    do: valid_utc(Date, message_data, field_name, required?)

  def is_valid_time_utc(message_data, field_name, required?),
    do: valid_utc(Time, message_data, field_name, required?)

  defp valid_utc(date_type, message_data, field_name, :not_required) do
    from_iso8601(date_type, message_data, field_name)
  end

  defp valid_utc(date_type, message_data, field_name, :required) do
    RequiredValidator.required(message_data, field_name, fn message_data, field_name ->
      from_iso8601(date_type, message_data, field_name)
    end)
  end

  defp invalid_date_msg(DateTime), do: :invalid_datetime
  defp invalid_date_msg(Date), do: :invalid_date
  defp invalid_date_msg(Time), do: :invalid_time

  def from_iso8601(date_type, message_data, field_name) when is_map(message_data) do
    datetime = Utils.safe_get(message_data, field_name)

    case(from_iso8601(date_type, datetime)) do
      {:ok, value, _} ->
        if value, do: ok(field_name, value), else: ok()

      {:ok, value} ->
        if value, do: ok(field_name, value), else: ok()

      {:error, err} ->
        Logger.debug(fn -> "Error encountered while parsing from_iso8601: #{inspect(err)}" end)
        {:error, {invalid_date_msg(date_type), field_name, datetime}}
    end
  end

  def from_iso8601(_date_type, _message_data, _field_name),
    do: {:error, :message_data_must_be_a_map}

  def from_iso8601(_date_type, nil = _datetime), do: {:ok, nil}
  def from_iso8601(_date_type, %Date{} = date), do: {:ok, date}
  def from_iso8601(_date_type, %Time{} = time), do: {:ok, time}
  def from_iso8601(_date_type, %DateTime{} = datetime), do: {:ok, datetime}
  def from_iso8601(_date_type, {:error, _} = err), do: err
  def from_iso8601(date_type, datetime), do: date_type.from_iso8601(datetime)
end
