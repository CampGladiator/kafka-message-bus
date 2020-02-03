defmodule KafkaMessageBus.Config do
  @moduledoc """
  A set of functions that help retrieve config data.
  """
  @lib_name :kafka_message_bus

  def get_adapters!, do: get_required_config!(:adapters)

  def get_adapter_config!(adapter), do: get_required_config!(adapter)

  def default_topic!, do: get_required_config!(:default_topic)

  def source!, do: get_required_config!(:source)

  def message_contracts!, do: get_required_config!(:message_contracts)

  def get_required_config!(setting) do
    case Application.get_env(@lib_name, setting) do
      nil -> raise "Failed to find config setting: #{inspect(setting)}"
      value -> value
    end
  end

  # FUTURE: Consolidate config calls to this module?
end
