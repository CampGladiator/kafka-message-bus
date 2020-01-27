defmodule KafkaMessageBus do
  @moduledoc """
  Set of functions that can be used by the app that depends on the kafka message bus. This serves
  as an entry point to the app for producers.
  """
  alias KafkaMessageBus.Producer

  def produce(data, key, resource, action, opts \\ []) do
    Producer.produce(data, key, resource, action, opts)
  end

  def producer(opts) do
    {resource, opts} = Keyword.pop(opts, :resource)

    quote do
      defp produce(message, key, action) do
        unquote(__MODULE__).produce(message, key, unquote(resource), action, unquote(opts))
      end
    end
  end

  defmacro __using__([{which, opts}]) do
    apply(__MODULE__, which, [opts])
  end
end
