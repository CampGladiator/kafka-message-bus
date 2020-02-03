defmodule KafkaMessageBus.Application do
  @moduledoc """
  Application module for KafkaMessageBus. This kicks off the supervisor for
  the app using the one_for_one strategy (restart failed processes only).
  """
  alias KafkaMessageBus.Config

  use Application

  #TODO: raise informative error if config is not properly set
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

#  defp on_start() do
#
#  end
end
