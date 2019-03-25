defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def perform(module, message) do
    Logger.debug(fn ->
      "Exq message received"
    end)

    ConsumerHandler.perform(module, message)
  end
end
