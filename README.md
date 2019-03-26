# KafkaMessageBus

A general purpose message bus.

## Installation

The package can be installed by adding `kafka_message_bus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_message_bus, "~> 3.0"}]
end
```

## Usage

The following configuration is expected:

```elixir
config :kafka_message_bus,
  source: "source",
  default_topic: "default_topic",
  adapters: [
    AdapterModule
  ]
```

Where:

|Field          |Description                                               |
|---------------|----------------------------------------------------------|
|`source`       |The reported message source                               |
|`default_topic`|The default topic for any generated message               |
|`adaters`      |A list of adapter modules. `Exq` and `Kaffe` are provided.|

The adapters themselves also require some configuration.

```elixir
config :kafka_message_bus, KafkaMessageBus.Adapters.Kaffe,
  consumers: [
    {"kafka_topic", "kafka_resource", YourApp.ResourceConsumer}
  ],
  producers: ["another_topic"],
  endpoints: ["first-broker": 9092, "second-broker": 9092],
  namespace: "kafka_consumer_group"
```
