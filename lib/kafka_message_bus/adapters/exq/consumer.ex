defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  @moduledoc """
  Consumer module for Exq.
  """
  alias KafkaMessageBus.{ConsumerHandler, Utils}

  require Logger

  def perform(module, message, consumer_handler \\ ConsumerHandler) do
    Logger.info(fn -> "Received Exq message" end)

    message = Poison.decode!(message)

    Utils.set_log_metadata(message)

    case consumer_handler.perform(module, message) do
      :ok ->
        :ok

      {:error, reason} ->
        err_msg = "consumer_handler.perform failed due to: #{inspect(reason)}"
        Logger.error(fn -> err_msg end)
        raise reason
    end

    Utils.clear_log_metadata()
  rescue
    e ->
      Utils.clear_log_metadata()

      reraise e, __STACKTRACE__
  end
end
