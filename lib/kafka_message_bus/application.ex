defmodule KafkaMessageBus.Application do
  alias KafkaMessageBus.Config

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = Config.get_adapters_supervisors()

    Supervisor.start_link(children, strategy: :one_for_one)

    # ([supervisor(GroupMemberSupervisor, [])] ++ Config.queue_supervisor())
    # |> Supervisor.start_link(
    # strategy: :one_for_one,
    # name: KafkaMessageBus.Supervisor
    # )
  end
end
