# KafkaMessageBus

A general purpose message bus.

## Installation

The package can be installed by adding `kafka_message_bus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:kafka_message_bus, "~> 3.0"}]
end
```

And, for now, this configuration is required:

```elixir
config :exq,
  start_on_application: false
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

The kafka_message_bus supports injecting message data validators to enforce 
message contracts on data passed through the bus. There is no message data 
validation by default and the related configuration settings are not required.

To control which message contracts are enforced use the following 
configuration settings:
```elixir
config :kafka_message_bus, :message_contracts, validation_exclusions: :none
```
Will enforce all message contracts.
```elixir
config :kafka_message_bus, :message_contracts, validation_exclusions: :all
```
Will exclude all message contract enforcement. Message processing 
will continue to work as it has in the past. 
```elixir
config :kafka_message_bus, :message_contracts, 
validation_exclusions: [MessageDataImplementation1, MessageDataImplementation2]
```
Will exclude message_contracts by name.
