defmodule KafkaMessageBus.ConsumerHandler do
  @moduledoc """
  Contains perform/2 function that is used to consume a message using the
  specified module.
  """
  alias KafkaMessageBus.{MessageDataValidator, Utils}

  require Logger

  def perform(module, message) when is_binary(module) do
    module = String.to_existing_atom(module)

    perform(module, message)
  end

  def perform(module, message) do
    Logger.debug(fn ->
      "Running #{Utils.to_module_short_name(module)} message handler"
    end)

    case MessageDataValidator.validate(message) do
      {:ok, :message_contract_excluded} ->
        Logger.info(fn ->
          "Message contract (consume) excluded: message=#{inspect(message)}"
        end)

        consume(module, message)

      {:ok, message_data} ->
        m = Map.put(message, "data", message_data)
        consume(module, m)

      {:error, [] = validation_errors} ->
        Logger.warn(fn ->
          "Validation failed for message_data consumption: #{inspect(validation_errors)}\n#{
            inspect(message)
          }"
        end)

        {:error, validation_errors}

      {:error, :unrecognized_message_data_type} ->
        Logger.error(fn ->
          "Attempting to consume unrecognized message data type: #{inspect(message)}"
        end)

        # DEPRECATED: We currently try to consume messages that are not recognized by
        #   the validator but want an error to be returned in the future. This may be
        #   changed once all the apps that depend on kafka_message_bus are updated to
        #   support the currently known message contracts.
        consume(module, message)

      err ->
        Logger.error(fn ->
          "Unexpected response encountered when validating consumer message data: #{inspect(err)}"
        end)

        err
    end
  rescue
    e ->
      err_msg =
        "Failed to process module. module: #{inspect(module)}" <>
          ", error: #{inspect(e)}" <> ", message: #{inspect(message)}"

      Logger.error(fn -> err_msg end)
      {:error, e}
  end

  defp consume(module, message) do
    case module.process(message) do
      :ok ->
        :ok

      {:ok, _} ->
        :ok

      {:error, reason} = result ->
        Logger.error(fn ->
          "Error encountered while executing module.process/1: #{inspect(reason)}"
        end)

        result

      other ->
        Logger.warn(fn ->
          "Unexpected response when executing module.process/1: #{inspect(other)}"
        end)

        {:error, other}
    end
  end
end
