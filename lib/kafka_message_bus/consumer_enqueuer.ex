defmodule KafkaMessageBus.ConsumerEnqueuer do
  @moduledoc """
  Legacy dead letter queue handler.

  This is not used directly anymore but is still necessary in case old messages
  are being reprocessed.
  """

  require Logger

  def perform(msg_content, message_processor) do
    Logger.info("Retrying message with content: #{inspect(msg_content)}")

    message_processor
    |> String.to_atom()
    |> (fn processor -> processor.process(msg_content) end).()
  end
end
