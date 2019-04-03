defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  alias KafkaMessageBus.{ConsumerHandler, Utils}

  require Logger

  def perform(module, message) do
    Logger.info(fn ->
      "Received Exq message"
    end)

    Utils.set_log_metadata(message)

    :ok = ConsumerHandler.perform(module, message)
  rescue
    e ->
      Utils.clear_log_metadata()

      raise e
  end
end
