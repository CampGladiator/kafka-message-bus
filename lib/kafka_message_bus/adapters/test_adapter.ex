defmodule KafkaMessageBus.Adapters.TestAdapter do
  @behaviour KafkaMessageBus.Adapter

  use Agent

  alias KafkaMessageBus.Config

  def init(config) do
    import Supervisor.Spec

    child = worker(Agent, [fn -> build_initial_state(config) end, [name: __MODULE__]])

    {:ok, child}
  end

  defp build_initial_state(config) do
    %{
      producers: config[:producers],
      messages: %{}
    }
  end

  def produce(message, opts) do
    topic = Keyword.get(opts, :topic, Config.default_topic())

    if topic not in Agent.get(__MODULE__, & &1.producers) do
      {:error, :unknown_topic}
    else
      key = self()

      Agent.update(__MODULE__, fn state ->
        messages = Map.get(state.messages, key, [])

        %{state | messages: Map.put(state.messages, key, [message | messages])}
      end)
    end
  end

  def get_produced_messages() do
    key = self()
    
    Agent.get(__MODULE__, fn state -> Map.get(state.messages, key) end)
  end
end
