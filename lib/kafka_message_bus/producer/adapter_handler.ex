defmodule KafkaMessageBus.Producer.AdapterHandler do
  @moduledoc """
  A set of functions that handles adapters for KafkaMessageBus.Producer. This code was
  originally extracted from Producer.
  """
  alias KafkaMessageBus.{Config, Utils}
  require Logger

  def process_adapters(message, opts, topic),
    do:
      topic
      |> get_adapters_for_topic()
      |> process_adapters(message, opts, topic)

  def process_adapters(adapters, _message, _opts, topic)
      when is_list(adapters) and adapters == [],
      do: topic_adapters_not_found(topic)

  def process_adapters(adapters, message, opts, _topic) when is_list(adapters) do
    adapters
    |> Enum.map(fn adapter ->
      Logger.debug(fn ->
        "Producing message with #{Utils.to_module_short_name(adapter)} adapter"
      end)

      {adapter, adapter.produce(message, opts), message}
    end)
    |> Enum.each(&handle_adapter_result/1)
  end

  defp handle_adapter_result({adapter, :ok, _message}) do
    Logger.debug(fn ->
      "Message successfully produced by #{Utils.to_module_short_name(adapter)} adapter"
    end)

    :ok
  end

  defp handle_adapter_result({adapter, error, message}) do
    Logger.error(fn ->
      "Failed to send message using #{Utils.to_module_short_name(adapter)}: #{inspect(error)} for message_data: #{
        inspect(message)
      }"
    end)

    {:error, error}
  end

  def get_adapters_for_topic(topic) do
    Config.get_adapters!()
    |> Enum.flat_map(fn adapter ->
      config = Config.get_adapter_config!(adapter)
      if topic in config[:producers], do: [adapter], else: []
    end)
  end

  def topic_adapters_not_found(topic) do
    Logger.warn(fn -> "Found no adapters for #{topic}" end)
    {:error, :topic_adapters_not_found}
  end
end
