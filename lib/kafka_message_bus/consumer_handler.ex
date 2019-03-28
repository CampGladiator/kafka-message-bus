defmodule KafkaMessageBus.ConsumerHandler do
  def perform(module, message) when is_binary(module) do
    module = String.to_existing_atom(module)

    perform(module, message)
  end

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
