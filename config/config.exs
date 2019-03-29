use Mix.Config

config :kafka_message_bus,
  source: "kafka-message-bus",
  default_topic: "custom_kafka_topic",
  adapters: [
    KafkaMessageBus.Adapters.Exq,
    KafkaMessageBus.Adapters.Kaffe
  ]

config :kafka_message_bus, KafkaMessageBus.Adapters.Exq,
  consumers: [
    {"custom_job_queue", "example_resource", KafkaMessageBusTest.Adapters.Exq.CustomJobConsumer}
  ],
  producers: ["some_queue"],
  endpoints: [localhost: 6379],
  namespace: "message_bus_namespace"

config :kafka_message_bus, KafkaMessageBus.Adapters.Kaffe,
  consumers: [
    {"custom_kafka_topic", "another_resource",
     KafkaMessageBusTest.Adapters.Kaffe.CustomJobConsumer}
  ],
  producers: ["some_topic"],
  endpoints: [localhost: 9092],
  namespace: "message_bus_consumer_group"

config :logger,
  backends: [:console],
  level: :debug
