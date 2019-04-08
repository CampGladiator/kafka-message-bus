defmodule KafkaMessageBus do
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
