defmodule KafkaMessageBus.Producer do
  @moduledoc false

  require Logger

  alias KafkaMessageBus.Config

  def produce(data, key, resource, action, opts \\ []) do
    topic = Keyword.get(opts, :topic, Config.default_topic())
    source = Keyword.get(opts, :source, Config.source())

    message = %{
      source: source,
      action: action,
      resource: resource,
      timestamp: DateTime.utc_now(),
      request_id: Logger.metadata() |> Keyword.get(:request_id),
      data: data |> Map.delete(:__meta__)
    }

    opts = Keyword.put(opts, :key, key)

    topic
    |> get_adapters_for_topic()
    |> case do
      [] ->
        {:error, :topic_not_found}

      adapters ->
        adapters
        |> Enum.map(fn adapter -> {adapter, adapter.produce(message, opts)} end)
        |> Enum.each(fn
          {adapter, :ok} ->
            Logger.debug(fn -> "Message produced by #{inspect(adapter)}" end)

          {adapter, reason} ->
            Logger.error(fn ->
              "Failed to send message by #{inspect(adapter)}: #{inspect(reason)}"
            end)
        end)
    end
  end

  defp get_adapters_for_topic(topic) do
    :kafka_message_bus
    |> Application.get_env(:adapters)
    |> Enum.flat_map(fn adapter ->
      config = Application.get_env(:kafka_message_bus, adapter)

      if topic in config[:producers] do
        [adapter]
      else
        []
      end
    end)
  end
end
