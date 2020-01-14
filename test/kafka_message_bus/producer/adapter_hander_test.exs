defmodule KafkaMessageBus.Producer.AdapterHandlerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.Producer.AdapterHandler

  describe "process_adapters" do
    test "should work" do
      fun = fn ->
        adapters = [KafkaMessageBus.Adapters.TestAdapter, KafkaMessageBus.Adapters.TestAdapter]
        message = %{}

        assert :ok ==
                 AdapterHandler.process_adapters(
                   adapters,
                   message,
                   [topic: "default_topic"],
                   "default_topic"
                 )
      end

      assert capture_log(fun) =~ "[debug] Producing message with TestAdapter adapter"

      assert capture_log(fun) =~ "[debug] Message successfully produced by TestAdapter"
    end

    test "should return error if provided empty list of adapters" do
      adapters = []
      message = %{}

      fun = fn ->
        assert {:error, :topic_adapters_not_found} ==
                 AdapterHandler.process_adapters(
                   adapters,
                   message,
                   [topic: "unk"],
                   "default_topic"
                 )
      end

      assert capture_log(fun) =~ "Found no adapters for default_topic"
    end
  end

  describe "get_adapters_for_topic" do
    test "get adapters for recognized topics" do
      assert AdapterHandler.get_adapters_for_topic("default_topic") == [
               KafkaMessageBus.Adapters.TestAdapter
             ]

      assert AdapterHandler.get_adapters_for_topic("secondary_topic") == [
               KafkaMessageBus.Adapters.TestAdapter
             ]
    end

    test "returns empty list for unrecognized topics" do
      refute Enum.any?(AdapterHandler.get_adapters_for_topic("what-kind-of-topic-is-this?"))
    end
  end
end
