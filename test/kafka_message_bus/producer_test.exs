defmodule KafkaMessageBus.ProducerTest do
  use ExUnit.Case

  alias Ecto.Association.NotLoaded
  alias KafkaMessageBus.Adapters.TestAdapter
  alias KafkaMessageBus.Producer

  @moduletag :capture_log

  describe "produce/5" do
    test "produces messages to the configured adapter" do
      message = %{"data" => "here"}

      Producer.produce(message, "key", "resource", "action")
      assert [produced_message] = TestAdapter.get_produced_messages()
      assert produced_message["data"] == message
    end

    test "produces messages without not loaded associations on it" do
      message = %{"data" => %NotLoaded{}}
      Producer.produce(message, "key", "resource", "action")
      assert [produced_message] = TestAdapter.get_produced_messages()
      assert produced_message["data"] == %{}
    end

    test "fails to produce to topics that have no adapters" do
      message = %{"data" => "here"}
      assert {:error, :topic_not_found} = Producer.produce(message, "key", "resource", "action", topic: "invalid_topic")
    end
  end
end
