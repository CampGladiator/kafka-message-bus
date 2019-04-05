defmodule KafkaMessageBus.ProducerTest do
  use ExUnit.Case

  alias KafkaMessageBus.Producer
  alias KafkaMessageBus.Adapters.TestAdapter

  @moduletag :capture_log

  describe "producing messages" do
    test "it produces messages to the configured adapter" do
      message = %{"data" => "here"}

      Producer.produce(message, "key", "resource", "action")

      [produced_message] = TestAdapter.get_produced_messages()

      assert produced_message["data"] == message
    end

    test "it fails to produce to topics that have no adapters" do
      message = %{"data" => "here"}

      assert {:error, :topic_not_found} =
               Producer.produce(message, "key", "resource", "action", topic: "invalid_topic")
    end
  end
end
