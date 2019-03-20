defmodule KafkaMessageBus.Adapter do
  @type config :: Map.t()

  @type name :: atom() | pid()
  @type reason :: any()

  @type message :: Map.t()
  @type topic :: String.t()
  @type resource :: String.t()

  @callback start_link(config) :: {:ok, name} | {:error, reason}
  @callback produce(message, topic, resource) :: :ok | {:error, reason}
end
