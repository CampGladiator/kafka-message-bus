# KafkaMessageBus

A general purpose message bus.

## Releasing

To release a new version of kafka_message_bus in hex be sure to update the 'version' number under 'project' in mix.exs.  

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

The following configuration is required for message validation support. The
user must provide a message data factory implementation that presents n number
of on_create/3 functions. Each on_create function will invoke message_data 
new/1 function for a message data struct that also implements the MessageData
validate/1 function. This project includes a SampleMessageDataFactoryImplementation
that illustrates how to write one of these factory implementation modules.

```elixir
config :kafka_message_bus, :message_contracts,
  message_data_factory_implementation:
    KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation
```

To control which message contracts are enforced use the following 
configuration settings:

```elixir
config :kafka_message_bus, :message_contracts, exclusions: :none
```
Will enforce all message contracts.

```elixir
config :kafka_message_bus, :message_contracts, exclusions: :all
```
Will exclude all message contract enforcement. Message processing 
will continue to work as it has in the past. 

```elixir
config :kafka_message_bus, :message_contracts, 
  exclusions: [MessageDataImplementation1, MessageDataImplementation2]
```
Will exclude message_contracts by name.
