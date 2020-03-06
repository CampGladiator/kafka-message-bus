defmodule KafkaMessageBus.Producer do
  @moduledoc """
  This is the module that contains the producer functions. It is used directly
  by the KafkaMessageBus module.
  """
  alias KafkaMessageBus.{Config, MessageDataValidator}
  alias KafkaMessageBus.Producer.AdapterHandler
  require Logger

  def produce(data, key, resource, action, opts \\ []) do
    topic = Keyword.get(opts, :topic, Config.default_topic!())

    if Enum.any?(AdapterHandler.get_adapters_for_topic(topic)) do
      case MessageDataValidator.validate(data, resource, action) do
        {:ok, :message_contract_excluded} ->
          Logger.info(fn ->
            "Message contract (produce) excluded: resource=#{inspect(resource)}, action=#{
              inspect(action)
            }"
          end)

          on_produce(data, key, resource, action, opts, topic)

        {:ok, message_data} ->
          on_produce(message_data, key, resource, action, opts, topic)

        {:error, validation_errors} when is_list(validation_errors) ->
          Logger.warn(fn ->
            "Validation failed for message_data production: #{inspect(validation_errors)}\n#{
              get_produce_info(data, key, resource, action, opts, topic)
            }"
          end)

          {:error, validation_errors}

        {:error, :unrecognized_message_data_type} ->
          Logger.warn(fn ->
            "Attempting to produce unrecognized message data type: #{
              get_produce_info(data, key, resource, action, opts, topic)
            }"
          end)

          # DEPRECATED: we currently try to consume messages that are not recognized
          #   by the validator but want an error to be returned in the future
          on_produce(data, key, resource, action, opts, topic)
      end
    else
      AdapterHandler.topic_adapters_not_found(topic)
    end
  rescue
    err ->
      trace = Exception.format_stacktrace(__STACKTRACE__)

      Logger.error(fn ->
        "Unhandled error encountered in Producer.produce/5: #{inspect(err)}\n" <>
          "stacktrace: #{trace}\n" <>
          "produce_info: #{get_produce_info(data, key, resource, action, opts, nil)}"
      end)

      reraise err, __STACKTRACE__
  end

  def on_produce(data, key, resource, action, opts, topic, adapter_handler \\ AdapterHandler) do
    source = Keyword.get(opts, :source, Config.source!())

    Logger.info(fn ->
      key_log = if key != nil, do: "(key: #{key}) ", else: ""

      "Producing message on #{inspect(key_log)}:#{inspect(topic)}:#{inspect(resource)}:#{
        inspect(action)
      }"
    end)

    opts = Keyword.put(opts, :key, key)

    %{
      source: source,
      action: action,
      resource: resource,
      timestamp: DateTime.utc_now(),
      request_id: Keyword.get(Logger.metadata(), :request_id),
      data: remove_meta(data)
    }
    |> adapter_handler.process_adapters(opts, topic)
  end

  defp remove_meta(data) when is_map(data), do: Map.drop(data, [:__meta__, :__struct__])
  defp remove_meta(data), do: data

  def get_produce_info(data, key, resource, action, opts, topic) do
    produce_info =
      "key: #{inspect(key)}, resource: #{inspect(resource)}, action: #{inspect(action)}, topic: #{
        inspect(topic)
      }, opts: #{inspect(opts)}, message_data: #{inspect(data)}"

    if action =~ "nation_" do
      Logger.warn(fn ->
        "Realm module is attempting to produce a message that appears to originate from nation: #{
          produce_info
        }"
      end)
    end

    produce_info
  end
end
