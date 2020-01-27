defmodule KafkaMessageBus.Adapters.Exq.DeadLetterQueueConsumer do
  @moduledoc """
  Contains the process/1 function that will queue up the message for retry.
  """
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
