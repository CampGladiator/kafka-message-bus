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
    message =
      message
      |> Poison.encode!()
      |> Poison.decode!()
      |> Map.put("topic", topic)

    if topic in Agent.get(__MODULE__, & &1.producers) do
      key = self()

      Agent.update(__MODULE__, fn state ->
        messages = Map.get(state.messages, key, [])

        %{state | messages: Map.put(state.messages, key, [message | messages])}
      end)
    else
      {:error, :unknown_topic}
    end
  end

  def get_produced_messages do
    key = self()

    Agent.get(__MODULE__, fn state -> Map.get(state.messages, key) end)
  end

  def get_produced_messages(topic, resource, action) do
    key = self()

    Agent.get(__MODULE__, fn state ->
      state.messages
      |> Map.get(key)
      |> Enum.filter(fn message ->
        message["topic"] == topic and message["resource"] == resource and
          message["action"] == action
      end)
    end)
  end
end
