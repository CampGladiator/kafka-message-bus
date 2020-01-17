defmodule KafkaMessageBus.Utils do
  @moduledoc """
  A set of utility functions.
  """
  require Logger

  def to_module_short_name(adapter) do
    adapter
    |> Module.split()
    |> List.last()
  end

  def set_log_metadata(message) do
    Logger.metadata(
      request_id: message["request_id"],
      resource: message["resource"],
      action: message["action"],
      source: message["source"]
    )
  end

  def clear_log_metadata do
    Logger.metadata(
      request_id: nil,
      resource: nil,
      action: nil,
      source: nil
    )
  end
end
