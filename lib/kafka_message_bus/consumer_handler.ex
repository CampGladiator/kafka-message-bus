defmodule KafkaMessageBus.ConsumerHandler do
  def perform(module, message) do
    with :ok <- module.process(message) do
      :ok
    else
      {:error, reason} ->
        {:error, reason}
    end
  rescue
    e -> {:error, e}
  end
end
