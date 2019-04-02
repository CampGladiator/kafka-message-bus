defmodule KafkaMessageBus.ConsumerHandler do
  def perform(module, message) when is_binary(module) do
    module = String.to_existing_atom(module)

    perform(module, message)
  end

  def perform(module, message) do
    case module.process(message) do
      :ok -> :ok
      {:error, _reason} = result -> result
      other -> {:error, other}
    end
  rescue
    e -> {:error, e}
  end
end
