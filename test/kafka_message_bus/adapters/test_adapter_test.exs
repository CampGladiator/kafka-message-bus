defmodule KafkaMessageBus.Adapters.TestAdapterTest do
  use ExUnit.Case

  alias KafkaMessageBus.Adapters.TestAdapter

  @moduletag :capture_log

  describe "getting specific produced messages" do
    test "it should return an empty list if no messages are produced with filters" do
      messages =
        TestAdapter.get_produced_messages("default_topic", "some_resource", "some_action")

      assert Enum.empty?(messages)
    end

    test "it should return all produced messages that match a filter" do
      first_message = %{"some" => "data"}
      second_message = %{"data" => "again"}
      third_message = %{"more" => "data"}

      KafkaMessageBus.produce(first_message, "key", "resource", "action")
      KafkaMessageBus.produce(second_message, "key", "resource", "action")

      KafkaMessageBus.produce(third_message, "key", "other_resource", "action",
        topic: "secondary_topic"
      )

      produced_messages = TestAdapter.get_produced_messages("default_topic", "resource", "action")

      assert length(produced_messages) == 2

      messages_contents = Enum.map(produced_messages, fn item -> item["data"] end)

      assert first_message in messages_contents
      assert second_message in messages_contents
      refute third_message in messages_contents
    end

    test "it should return all matching produced messages when using different filters" do
      first_message = %{"some" => "data"}
      second_message = %{"data" => "again"}
      third_message = %{"more" => "data"}

      KafkaMessageBus.produce(first_message, "key", "some_resource", "some_action")
      KafkaMessageBus.produce(second_message, "key", "another_resource", "some_action")
      KafkaMessageBus.produce(third_message, "key", "another_resource", "another_action")

      assert [%{"data" => ^first_message}] =
               TestAdapter.get_produced_messages(
                 "default_topic",
                 "some_resource",
                 "some_action"
               )

      assert [%{"data" => ^second_message}] =
               TestAdapter.get_produced_messages(
                 "default_topic",
                 "another_resource",
                 "some_action"
               )

      assert [%{"data" => ^third_message}] =
               TestAdapter.get_produced_messages(
                 "default_topic",
                 "another_resource",
                 "another_action"
               )
    end

    test "it should only provide matching messages created by the current process" do
      first_message = %{"some" => "data"}
      second_message = %{"more" => "data"}

      KafkaMessageBus.produce(first_message, "key", "resource", "action")

      parent = self()

      spawn(fn ->
        KafkaMessageBus.produce(second_message, "key", "other_resource", "action",
          topic: "secondary_topic"
        )

        send(parent, :done)
      end)

      receive do
        :done -> :ok
      after
        1_000 -> raise "Expected spawned function to end"
      end

      produced_messages = TestAdapter.get_produced_messages("default_topic", "resource", "action")

      assert length(produced_messages) == 1

      messages_contents = Enum.map(produced_messages, fn item -> item["data"] end)

      assert first_message in messages_contents
      refute second_message in messages_contents
    end
  end

  describe "getting all produced messages" do
    test "it should return an empty list if no messages are produced" do
      messages = TestAdapter.get_produced_messages()

      assert Enum.empty?(messages)
    end

    test "it should return all produced messages" do
      first_message = %{"some" => "data"}
      second_message = %{"data" => "again"}

      KafkaMessageBus.produce(first_message, "key", "resource", "action")
      KafkaMessageBus.produce(second_message, "key", "resource", "action")

      produced_messages = TestAdapter.get_produced_messages()

      assert length(produced_messages) == 2

      messages_contents = Enum.map(produced_messages, fn item -> item["data"] end)

      assert first_message in messages_contents
      assert second_message in messages_contents
    end

    test "it should only provide messages created by the current process" do
      first_message = %{"some" => "data"}
      second_message = %{"more" => "data"}

      KafkaMessageBus.produce(first_message, "key", "resource", "action")

      parent = self()

      spawn(fn ->
        KafkaMessageBus.produce(second_message, "key", "resource", "action")

        send(parent, :done)
      end)

      receive do
        :done -> :ok
      after
        1_000 -> raise "Expected spawned function to end"
      end

      produced_messages = TestAdapter.get_produced_messages()

      assert length(produced_messages) == 1

      messages_contents = Enum.map(produced_messages, fn item -> item["data"] end)

      assert first_message in messages_contents
      refute second_message in messages_contents
    end
  end
end
