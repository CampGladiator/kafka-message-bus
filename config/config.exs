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
    {"job_queue", "job_resource", KafkaMessageBusTest.Adapters.Exq.CustomJobConsumer},
    {"dead_letter_queue", nil, KafkaMessageBus.Adapters.Exq.DeadLetterQueueConsumer, concurrency: 600}
  ],
  producers: ["job_queue", "dead_letter_queue"],
  endpoints: [localhost: 6379],
  namespace: "message_bus_namespace",
  concurrency: 100

config :kafka_message_bus, KafkaMessageBus.Adapters.Kaffe,
  consumers: [
    {"kafka_topic", "kafka_resource", KafkaMessageBusTest.Adapters.Kaffe.CustomJobConsumer}
  ],
  producers: ["another_topic"],
  endpoints: [localhost: 9092],
  namespace: "message_bus_consumer_group"

config :exq,
  start_on_application: false

config :logger,
  backends: [:console],
  level: :debug

import_config "#{Mix.env()}.exs"
