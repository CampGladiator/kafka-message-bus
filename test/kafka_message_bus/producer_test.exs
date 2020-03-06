defmodule KafkaMessageBus.ProducerTest do
  import ExUnit.CaptureLog
  use ExUnit.Case

  alias KafkaMessageBus.Adapters.TestAdapter
  alias KafkaMessageBus.Producer

  @moduletag :capture_log

  describe "producing messages" do
    test "it produces messages to the configured adapter" do
      message = %{
        "id" => nil,
        "alt_id" => 12_345,
        "field1" => "abc",
        "field2" => "2019-10-11T10:09:08Z",
        "field3" => 234.0,
        "nested_optional" => nil
      }

      assert :ok == Producer.produce(message, "key", "sample_resource", "sample_action")

      [produced_message] = TestAdapter.get_produced_messages()

      assert produced_message["data"] == message
    end

    test "it fails to produce to topics that have no adapters" do
      message = %{"data" => "here"}

      assert {:error, :topic_adapters_not_found} =
               Producer.produce(message, "key", "resource", "action", topic: "invalid_topic")
    end

    test "should return error with validation errors list on validation fail" do
      message = %{"data" => "here"}

      result = Producer.produce(message, "key", "sample_resource", "sample_action")

      assert result ==
               {:error,
                [
                  id: {"One of these fields must be present: [:id, :alt_id]", []},
                  field1: {"can't be blank", [validation: :required]},
                  field2: {"can't be blank", [validation: :required]}
                ]}
    end

    test "should warn if Elixir code is trying to create a nation message" do
      message = %{"data" => "here"}

      fun = fn ->
        assert :ok == Producer.produce(message, "key", "resource", "nation_action")
      end

      assert capture_log(fun) =~
               "[warn]  Realm module is attempting to produce a message that appears to originate from nation"
    end

    test "should exclude message data types included in exclusions list in config" do
      message = %{"data" => "here"}

      fun = fn ->
        assert :ok == Producer.produce(message, "key", "sample_resource", "sample_exclusion")
      end

      assert capture_log(fun) =~ "[info]  Message contract (produce) excluded"
    end
  end

  describe "get_produce_info" do
    test "should return expected value" do
      result =
        Producer.get_produce_info(
          %{the_data: "the data"},
          "key",
          "resource",
          "action",
          ["opts"],
          "topic"
        )

      assert result ==
               "key: \"key\", resource: \"resource\", action: \"action\", topic: \"topic\", opts: [\"opts\"], message_data: %{the_data: \"the data\"}"
    end
  end
end
