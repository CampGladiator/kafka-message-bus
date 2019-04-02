defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def perform(module, message) do
    Logger.info(fn ->
      "Received Exq message"
    end)

    :ok = ConsumerHandler.perform(module, message)
  end
end
