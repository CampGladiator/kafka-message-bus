defmodule KafkaMessageBus.Messages.MessageData.ValidatorTest do
  use ExUnit.Case
  alias KafkaMessageBus.Examples.SampleMessageData

  test "this" do
    data = %{
      "id" => nil,
      "alt_id" => 12_345,
      "field1" => "abc",
      "field2" => "2019-10-11T10:09:08Z",
      "field3" => "234"
    }

    changeset = SampleMessageData.changeset(%SampleMessageData{}, data)
    {:ok, field3_val, _} = DateTime.from_iso8601("2019-10-11 10:09:08Z")

    assert changeset.valid?

    assert changeset.changes == %{
             alt_id: 12_345,
             field1: "abc",
             field2: field3_val,
             field3: 234.0
           }
  end
end
