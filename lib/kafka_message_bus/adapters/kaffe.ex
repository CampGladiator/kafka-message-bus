defmodule KafkaMessageBus.Adapters.Kaffe do
  @moduledoc """
  Implements adapter behavior for Kafka (via Kaffe).
  """

  alias Kaffe.Producer

  alias KafkaMessageBus.{
    Adapter,
    Adapters.Kaffe.Consumer,
    Config
  }

  require Logger

  @behaviour Adapter

  @impl Adapter
  def init(config) do
    Logger.info(fn ->
      "Initializing Kaffe adapter"
    end)

    config
    |> to_kaffe_config()
    |> apply_kaffe_config()

    Logger.debug(fn ->
      "Kaffe configuration applied"
    end)

    start_kaffe()
  end

  @impl Adapter
  def produce(message, opts) do
    topic = Keyword.get(opts, :topic, Config.default_topic())
    key = Keyword.get(opts, :key)
    message = Jason.encode!(message)

    Producer.produce_sync(topic, [{key, message}])
  end

  defp to_kaffe_config(config) do
    [
      kafka_mod: :brod,
      app_consumers: config[:consumers]
    ]
    |> add_consumer_config(config)
    |> add_producer_config(config)
  end

  defp add_consumer_config(base_config, external_config) do
    consumer_topics =
      external_config[:consumers]
      |> Enum.map(fn entry ->
        entry
        |> Tuple.to_list()
        |> List.first()
      end)
      |> Enum.uniq()
      |> case do
        [] -> [List.first(external_config[:producers])]
        other -> other
      end

    base_config ++
      [
        consumer: [
          heroku_kafka_env: false,
          endpoints: external_config[:endpoints],
          topics: consumer_topics,
          consumer_group: external_config[:namespace],
          message_handler: Consumer,
          async_message_ack: false,
          offset_commit_interval_seconds: 10,
          start_with_earliest_message: false,
          rebalance_delay_ms: 100,
          max_bytes: 10_000,
          subscriber_retries: 5,
          subscriber_retry_delay_ms: 5,
          worker_allocation_strategy: :worker_per_topic_partition
        ]
      ]
  end

  defp add_producer_config(base_config, external_config) do
    if external_config[:producers] == [] do
      base_config
    else
      base_config ++
        [
          producer: [
            partition_strategy: :md5,
            endpoints: external_config[:endpoints],
            topics: external_config[:producers]
          ]
        ]
    end
  end

  defp apply_kaffe_config(config) do
    Enum.each(config, fn {key, value} ->
      Application.put_env(:kaffe, key, value)
    end)
  end

  defp start_kaffe do
    import Supervisor.Spec

    {:ok, _} = Application.ensure_all_started(:kaffe)

    {:ok, worker(Kaffe.Consumer, [])}
  end
end
