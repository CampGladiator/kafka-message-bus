defmodule KafkaMessageBus.Config do
  @moduledoc """
  A set of functions that help retrieve config data.
  """
  @lib_name :kafka_message_bus

  #TODO: return informative error if environment variables not found
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

  #TODO: Consolidate config calls to this module (message contract settings, for instance)
end
