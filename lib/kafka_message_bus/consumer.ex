defmodule KafkaMessageBus.Consumer do
  @moduledoc """
  Defines behaviors for kafka message bus consumers. The apps depending on this app
  will implement these.
  """
  @type msg_content :: Map.t()
  @type msg_error :: String.t()

  @callback process(msg_content) :: :ok | {:error, msg_error}
end
