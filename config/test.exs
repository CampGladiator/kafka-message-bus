use Mix.Config

config :logger,
  level: :debug

config :logger, :console, metadata: :all

config :kafka_message_bus,
  source: "kafka-message-bus",
  default_topic: "default_topic",
  adapters: [KafkaMessageBus.Adapters.TestAdapter]

config :kafka_message_bus, KafkaMessageBus.Adapters.TestAdapter,
  producers: ["default_topic", "secondary_topic"]

config :kafka_message_bus, :message_contracts,
  exclusions: [KafkaMessageBus.Examples.SampleExclusion],
  message_data_factory_implementation:
    KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation
