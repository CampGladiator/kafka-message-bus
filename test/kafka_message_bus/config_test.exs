defmodule KafkaMessageBus.ConfigTest do
  use ExUnit.Case
  alias KafkaMessageBus.Config

  describe "get_required_config!" do
    test "returns value if found" do
      assert Config.get_required_config!(:adapters) == [KafkaMessageBus.Adapters.TestAdapter]
    end

    test "raises error if not found" do
      fun = fn ->
        Config.get_required_config!(:unknown)
      end

      assert_raise(RuntimeError, fun)
    end
  end

  describe "config settings" do
    test "adapters" do
      assert Config.get_adapters!() == [KafkaMessageBus.Adapters.TestAdapter]
    end

    test "get_adapter_config" do
      assert Config.get_adapter_config!(KafkaMessageBus.Adapters.TestAdapter) == [
               {:producers, ["default_topic", "secondary_topic"]}
             ]
    end

    test "default_topic" do
      assert Config.default_topic!() == "default_topic"
    end

    test "source" do
      assert Config.source!() == "kafka-message-bus"
    end

    test "message_contracts" do
      assert Config.message_contracts!() == [
               exclusions: [KafkaMessageBus.Examples.SampleExclusion],
               message_data_factory_implementation: KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation
             ]
    end
  end
end
