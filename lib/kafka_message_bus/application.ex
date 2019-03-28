defmodule KafkaMessageBus.Application do
  alias KafkaMessageBus.Config

  use Application

  def start(_type, _args) do
    Config.get_adapters()
    |> Enum.flat_map(fn adapter ->
      adapter
      |> Config.get_adapter_config()
      |> adapter.init()
      |> case do
        {:ok, child} -> [child]
        :ok -> []
      end
    end)
    |> Supervisor.start_link(strategy: :one_for_one)
  end
end
