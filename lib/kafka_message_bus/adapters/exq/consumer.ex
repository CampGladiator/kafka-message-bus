defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def perform(module, message) do
    :ok = ConsumerHandler.perform(module, message)
  end
end
