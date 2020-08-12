defmodule KafkaMessageBus.Messages.MessageData.SampleMessageDataFactoryImplementationTest do
  import ExUnit.CaptureLog
  use ExUnit.Case
  alias KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation

  test "returns mapped message data types" do
    fun = fn ->
      {:ok, result} = SampleMessageDataFactoryImplementation.on_create(%{}, "sample_resource", "sample_action")

      assert result.__struct__ == KafkaMessageBus.Examples.SampleMessageData
    end

    assert capture_log(fun) =~ "[info]  Creating for sample_resource and sample_action: %{}"
  end

  test "can be validated" do
    fun = fn ->
      {:error, result} = SampleMessageDataFactoryImplementation.on_create(%{}, "unknown", "sample_action")

      assert result == :unrecognized_message_data_type
    end

    assert capture_log(fun) =~
             "[warn]  Encountered unrecognized message type for resource: unknown, action: sample_action."
  end
end
