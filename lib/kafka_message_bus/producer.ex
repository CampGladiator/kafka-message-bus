defmodule KafkaMessageBus.Producer do
  @moduledoc """
  This is the module that contains the producer functions. It is used directly
  by the KafkaMessageBus module.
  """

  alias Ecto.Association.NotLoaded
  alias KafkaMessageBus.{Config, Utils}

  require Logger

  @invalid_element_keys [:__meta__, :__struct__]

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
      data: remove_invalid_elements(data)
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
        |> produce_message_in_adapters(message, opts)
        |> Enum.each(&handle_adapter_result/1)
    end
  end

  defp remove_invalid_elements(data) when is_map(data) do
    data
    |> Map.to_list()
    |> Enum.reject(&is_invalid_element?/1)
    |> Map.new()
  end

  defp remove_invalid_elements(data), do: data

  defp is_invalid_element?(element) do
    case element do
      {key, _} when key in @invalid_element_keys -> true
      {_, %{__struct__: NotLoaded}} -> true
      {_, _} -> false
    end
  end

  defp produce_message_in_adapters(adapters, message, opts) do
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
