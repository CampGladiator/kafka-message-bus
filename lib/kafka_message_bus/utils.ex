defmodule KafkaMessageBus.Utils do
  def to_module_short_name(adapter) do
    adapter
    |> Module.split()
    |> List.last()
  end
end
