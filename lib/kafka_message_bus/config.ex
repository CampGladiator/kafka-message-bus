defmodule KafkaMessageBus.Config do
  @moduledoc """
  A set of functions that help retrieve config data.
  """
  @lib_name :kafka_message_bus

  def get_adapters do
    Application.get_env(@lib_name, :adapters)
  end

  def get_adapter_config(adapter) do
    Application.get_env(@lib_name, adapter)
  end

  def default_topic do
    Application.get_env(@lib_name, :default_topic)
  end

  def source do
    Application.get_env(@lib_name, :source)
  end
end
