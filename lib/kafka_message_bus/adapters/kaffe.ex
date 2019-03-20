defmodule KafkaMessageBus.Adapters.Kaffe do
  @behaviour KafkaMessageBus.Adapter

  @impl true
  def start_link(config) do
    config
    |> to_kaffe_config()
    |> apply_kaffe_config()

    start_kaffe()
  end

  defp to_kaffe_config(config) do
    topics =
      Enum.map(config[:consumers], fn entry ->
        entry
        |> Tuple.to_list()
        |> List.first()
      end)

    [
      consumer: [
        heroku_kafka_env: false,
        endpoints: config[:endpoints],
        topics: topics,
        consumer_group: config[:namespace],
        message_handler: KafkaMessageBus.Consumer,
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
        topics: topics
      ],
      kafka_mod: :brod
    ]
  end

  defp apply_kaffe_config(config) do
    Enum.each(config, fn {key, value} ->
      Application.put_env(:kaffe, key, value)
    end)
  end

  defp start_kaffe() do
    Kaffe.GroupMemberSupervisor.start_link()
  end
end
