defmodule KafkaMessageBus.Adapters.Kaffe.Consumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def handle_message(message) do
    IO.inspect(message)

    :ok
    # ConsumerHandler.perform(module, message)
  end
end
