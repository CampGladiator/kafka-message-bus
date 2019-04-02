defmodule KafkaMessageBus.Adapters.Kaffe do
  alias Kaffe.Producer

  alias KafkaMessageBus.Config
  alias KafkaMessageBus.Adapters.Kaffe.Consumer

  @behaviour KafkaMessageBus.Adapter

  @impl true
  def init(config) do
    config
    |> to_kaffe_config()
    |> apply_kaffe_config()

    start_kaffe()
  end

  @impl true
  def produce(message, opts) do
    topic = Keyword.get(opts, :topic, Config.default_topic())
    key = Keyword.get(opts, :key)

    message = Jason.encode!(message)

    Producer.produce_sync(topic, [{key, message}])
  end

  defp to_kaffe_config(config) do
    consumer_topics =
      config[:consumers]
      |> Enum.map(fn entry ->
        entry
        |> Tuple.to_list()
        |> List.first()
      end)
      |> Enum.uniq()

    [
      consumer: [
        heroku_kafka_env: false,
        endpoints: config[:endpoints],
        topics: consumer_topics,
        consumer_group: config[:namespace],
        message_handler: Consumer,
        async_message_ack: false,
        offset_commit_interval_seconds: 10,
        start_with_earliest_message: false,
        rebalance_delay_ms: 100,
        max_bytes: 10_000,
        subscriber_retries: 5,
        subscriber_retry_delay_ms: 5,
        worker_allocation_strategy: :worker_per_topic_partition
      ],
      producer: [
        partition_strategy: :md5,
        endpoints: config[:endpoints],
        topics: config[:producers]
      ],
      kafka_mod: :brod,
      app_consumers: config[:consumers]
    ]
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
