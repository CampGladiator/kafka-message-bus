use Mix.Config

config :logger,
  level: :error

config :kafka_message_bus,
  source: "kafka-message-bus",
  default_topic: "default_topic",
  adapters: [KafkaMessageBus.Adapters.TestAdapter]

config :kafka_message_bus, KafkaMessageBus.Adapters.TestAdapter,
  producers: ["default_topic", "secondary_topic"]
