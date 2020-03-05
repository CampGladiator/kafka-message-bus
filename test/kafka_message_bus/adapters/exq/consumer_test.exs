defmodule KafkaMessageBus.Adapters.Exq.ConsumerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.Adapters.Exq.Consumer

  describe "perform" do
    test "should decode json and call consumer handler" do
      json_data = ~s({"field1": "value1", "field2": "value2"})
      module = "Module"

      fun = fn ->
        Consumer.perform(module, json_data, MockConsumerHandler)
      end

      assert capture_log(fun) =~ "[info]  Received Exq message"

      assert capture_log(fun) =~
               "MockConsumerHandler: %{\"field1\" => \"value1\", \"field2\" => \"value2\"}"
    end

    test "rethrown exceptions" do
      json_data = ~s({"field1": 42, "field2": "value2"})
      module = "Module"

      fun = fn ->
        assert_raise(RuntimeError, fn ->
          Consumer.perform(module, json_data, MockConsumerHandler)
        end)
      end

      assert capture_log(fun) =~ "[info]  Received Exq message"
    end

    test "should handle error tuple returning from ConsumerHandler" do
      json_data = ~s({"field1": -42, "field2": "value2"})
      module = "Module"

      fun = fn ->
        assert_raise(RuntimeError, fn ->
          Consumer.perform(module, json_data, MockConsumerHandler)
        end)
      end

      assert capture_log(fun) =~
               "[error] consumer_handler.perform failed due to: \"Something went afoul!\""
    end
  end
end

defmodule ConsumerImplementation do
  def perform(_module, _message) do
    :ok
  end
end

defmodule MockConsumerHandler do
  def perform(_module, %{"field1" => 42} = _message) do
    raise "Something went afoul!"
  end

  def perform(_module, %{"field1" => -42} = _message) do
    {:error, "Something went afoul!"}
  end

  def perform(_module, message) do
    require Logger
    Logger.info(fn -> "MockConsumerHandler: " <> inspect(message) end)
    :ok
  end
end
