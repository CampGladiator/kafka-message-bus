defmodule KafkaMessageBus.Application do
  alias KafkaMessageBus.Config

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    Config.get_adapters()
    |> Enum.each(fn adapter ->
      config = Config.get_adapter_config(adapter)
      :ok = adapter.start_link(config)
    end)

    Supervisor.start_link([], strategy: :one_for_one)
  end
end
