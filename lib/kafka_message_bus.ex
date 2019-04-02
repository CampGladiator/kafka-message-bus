defmodule KafkaMessageBus do
  alias KafkaMessageBus.Producer

  def produce(data, key, resource, action, opts \\ []) do
    Producer.produce(data, key, resource, action, opts)
  end
end
