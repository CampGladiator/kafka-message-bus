defmodule KafkaMessageBus.ConsumerHandler do
  alias KafkaMessageBus.Utils

  require Logger

  def perform(module, message) when is_binary(module) do
    module = String.to_existing_atom(module)

    perform(module, message)
  end

  def perform(module, message) do
    Logger.info(fn ->
      "Running #{Utils.to_module_short_name(module)} message handler"
    end)

    case module.process(message) do
      :ok -> :ok
      {:error, _reason} = result -> result
      other -> {:error, other}
    end
  rescue
    e -> {:error, e}
  end
end
