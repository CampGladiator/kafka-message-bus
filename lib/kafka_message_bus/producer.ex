defmodule KafkaMessageBus.Producer do
  @moduledoc """
  This is the module that contains the producer functions. It is used directly
  by the KafkaMessageBus module.
  """
  alias KafkaMessageBus.{Config, MessageDataValidator}
  import KafkaMessageBus.Producer.AdapterHandler
  require Logger

  def produce(data, key, resource, action, opts \\ []) do
    topic = Keyword.get(opts, :topic, Config.default_topic())

    produce_info = get_produce_info(data, key, resource, action, opts, topic)

    if Enum.any?(get_adapters_for_topic(topic)) do
      case MessageDataValidator.validate(data, resource, action) do
        {:ok, :message_contract_excluded} ->
          Logger.debug(fn ->
            "Message contract (produce) excluded: resource=#{resource}, action=#{action}"
          end)

          produce(data, key, resource, action, opts, topic)

        {:ok, message_data} ->
          produce(message_data, key, resource, action, opts, topic)

        {:error, [] = validation_errors} ->
          # TODO: return exception or error tuple based on config setting.
          Logger.error(fn ->
            "Validation failed for message_data production: #{inspect(validation_errors)}\n#{
              produce_info
            }"
          end)

          {:error, validation_errors}

        {:error, :unrecognized_message_data_type} ->
          Logger.warn(fn ->
            "Attempting to produce unrecognized message data type: #{produce_info}"
          end)

          # DEPRECATED: we currently try to consume messages that are not recognized
          #   by the validator but want an error to be returned in the future
          produce(data, key, resource, action, opts, topic)

        err ->
          Logger.error(fn ->
            "Unexpected response encountered when validating producer message data: #{
              inspect(err)
            }"
          end)

          err
      end
    else
      topic_adapters_not_found(topic)
    end
  rescue
    # TODO: return exception instead
    err ->
      Logger.error(fn -> "Unhandled error encountered in Producer.produce/5: #{inspect(err)}" end)
      {:error, err}
  end

  defp produce(data, key, resource, action, opts, topic) do
    source = Keyword.get(opts, :source, Config.source())

    Logger.info(fn ->
      key_log = if key != nil, do: "(key: #{key}) ", else: ""

      "Producing message on #{key_log}#{topic}/#{resource}: #{action}"
    end)

    opts = Keyword.put(opts, :key, key)

    %{
      source: source,
      action: action,
      resource: resource,
      timestamp: DateTime.utc_now(),
      request_id: Keyword.get(Logger.metadata(), :request_id),
      data: Map.delete(data, :__meta__)
    }
    |> process_adapters(opts, topic)
  end

  defp get_produce_info(data, key, resource, action, opts, topic) do
    produce_info =
      "message_data: #{inspect(data)}, key: #{inspect(key)}, resource: #{inspect(resource)}, action: #{
        inspect(action)
      }, topic: #{inspect(topic)}, opts: #{inspect(opts)}"

    Logger.debug(fn -> "produce: #{produce_info}" end)

    if action =~ "nation_" do
      Logger.warn(fn ->
        "Realm module is attempting to produce a message that appears to originate from nation: #{
          produce_info
        }"
      end)
    end
  end
end
