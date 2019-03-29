defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  def perform(module, message) do
    IO.inspect({module, message})

    :ok
  end
end
