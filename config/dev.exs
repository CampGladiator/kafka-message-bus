use Mix.Config

config :logger,
  level: :debug

config :kafka_message_bus, :message_contracts,
  exclusions: :none,
  message_data_factory_implementation:
    KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation
