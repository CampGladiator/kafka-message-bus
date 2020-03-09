defmodule KafkaMessageBus.Messages.MessageData.MessageDataTypeTest do
  import ExUnit.CaptureLog
  use ExUnit.Case
  alias KafkaMessageBus.Examples.SampleMessageData
  alias KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation, as: Factory
  alias KafkaMessageBus.Messages.MessageData

  describe "map_struct" do
    test "should do a deep copy" do
      data = %{
        "id" => nil,
        "alt_id" => 12_345,
        "field1" => "abc",
        "field2" => "2019-10-11T10:09:08Z",
        "field3" => "234",
        "nested_optional" => %{
          "id" => "abc123",
          "field1" => "test"
        }
      }

      fun = fn ->
        {:ok, sample_data} = Factory.on_create(data, "sample_resource", "sample_action")
        {:ok, result} = MessageData.validate(sample_data)
        {:ok, field2_datetime, _} = DateTime.from_iso8601("2019-10-11 10:09:08Z")

        assert result.__struct__ == SampleMessageData
        refute result.id
        assert result.alt_id == 12_345
        assert result.field1 == "abc"
        assert result.field2 == field2_datetime
        assert result.field3 == 234.0
        assert result.nested_optional.__struct__ == KafkaMessageBus.Examples.SampleExclusion
        assert result.nested_optional.id == "abc123"
        assert result.nested_optional.field1 == "test"
      end

      assert capture_log(fun) =~ "[info]  Creating for sample_resource and sample_action:"
    end
  end

  describe "MessageData.validate" do
    test "should return struct with changes" do
      data = %{
        "id" => nil,
        "alt_id" => 12_345,
        "field1" => "abc",
        "field2" => "2019-10-11T10:09:08Z",
        "field3" => "234"
      }

      fun = fn ->
        {:ok, sample_data} = Factory.on_create(data, "sample_resource", "sample_action")
        {:ok, result} = MessageData.validate(sample_data)
        {:ok, field2_datetime, _} = DateTime.from_iso8601("2019-10-11 10:09:08Z")

        assert result.__struct__ == SampleMessageData
        refute result.id
        assert result.alt_id == 12_345
        assert result.field1 == "abc"
        assert result.field2 == field2_datetime
        assert result.field3 == 234.0
      end

      assert capture_log(fun) =~ "[info]  Creating for sample_resource and sample_action:"
    end
  end
end
