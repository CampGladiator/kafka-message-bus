defmodule KafkaMessageBus.Adapters.Exq.DeadLetterQueueConsumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def process(%{
        "action" => "retry",
        "data" => %{
          "consumer" => consumer,
          "message" => message
        }
      }) do
    :ok = ConsumerHandler.perform(consumer, message)
  end
end
