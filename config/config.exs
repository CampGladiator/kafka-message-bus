use Mix.Config

config :kafka_message_bus,
  adapters: [
    KafkaMessageBus.Adapters.Exq
    #    KafkaMessageBus.Adapters.Kaffe
  ]

config :kafka_message_bus, KafkaMessageBus.Adapters.Exq,
  consumers: [
    {"custom_job_queue", "example_resource", KafkaMessageBusTest.Adapters.Exq.CustomJobConsumer}
  ],
  endpoints: [localhost: 6379],
  namespace: "exq"

config :kafka_message_bus, KafkaMessageBus.Adapters.Kaffe,
  consumers: [
    {"custom_kafka_topic", "another_resource",
     KafkaMessageBusTest.Adapters.Kaffe.CustomJobConsumer}
  ],
  endpoints: [localhost: 9092],
  namespace: "kafka_message_bus"

config :kaffe,
  consumer: [
    endpoints: [localhost: 9092],
    topics: ["user"],
    consumer_group: "kafka_message_bus",
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
    endpoints: [localhost: 9092],
    topics: ["kafka_message_bus"]
  ],
  kafka_mod: :brod

config :logger,
  backends: [:console],
  level: :debug
