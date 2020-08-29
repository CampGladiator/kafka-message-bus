defmodule KafkaMessageBus.Producer do
  @moduledoc """
  This is the module that contains the producer functions. It is used directly
  by the KafkaMessageBus module.
  """

  alias KafkaMessageBus.{Config, Utils}

  require Logger

  def produce(data, key, resource, action, opts \\ []) do
    topic = Keyword.get(opts, :topic, Config.default_topic())
    source = Keyword.get(opts, :source, Config.source())

    Logger.info(fn ->
      key_log =
        if key != nil do
          "(key: #{key}) "
        else
          ""
        end

      "Producing message on #{key_log}#{topic}/#{resource}: #{action}"
    end)

    message = %{
      source: source,
      action: action,
      resource: resource,
      timestamp: DateTime.utc_now(),
      request_id: Keyword.get(Logger.metadata(), :request_id),
      data: Map.delete(data, :__meta__)
    }

    opts = Keyword.put(opts, :key, key)

    topic
    |> get_adapters_for_topic()
    |> case do
      [] ->
        Logger.error(fn -> "Found no adapters for #{topic}" end)
        {:error, :topic_not_found}

      adapters ->
        adapters
        |> produce_messages(message)
        |> Enum.each(&handle_adapter_result/1)
    end
  end

  defp produce_messages(adapters, message) do
    Enum.map(adapters, fn adapter ->
      Logger.debug(fn ->
        "Producing message with #{Utils.to_module_short_name(adapter)} adapter"
      end)

      {adapter, adapter.produce(message, opts)}
    end)
  end

  defp handle_adapter_result({adapter, :ok}) do
    Logger.debug(fn ->
      "Message successfully produced by #{Utils.to_module_short_name(adapter)} adapter"
    end)

    :ok
  end

  defp handle_adapter_result({adapter, error}) do
    Logger.error(fn ->
      "Failed to send message using #{Utils.to_module_short_name(adapter)}: #{inspect(error)}"
    end)

    {:error, error}
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
