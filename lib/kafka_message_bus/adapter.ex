defmodule KafkaMessageBus.Adapter do
  @moduledoc """
  This defines behaviors for message bus adapters.
  """
  @type config :: Map.t()
  @type reason :: any()
  @type message :: Map.t()
  @type opts :: Keyword.t()
  @type process_definition :: Supervisor.Spec.spec()

  @callback init(config) :: :ok | {:ok, process_definition} | {:error, reason}
  @callback produce(message, opts) :: :ok | {:error, reason}
end
