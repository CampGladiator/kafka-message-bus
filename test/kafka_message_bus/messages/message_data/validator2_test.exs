defmodule KafkaMessageBus.Messages.MessageData.Validator2Test do
  use ExUnit.Case
  import Ecto.Changeset
  alias KafkaMessageBus.Messages.MessageData.Validator
  alias KafkaMessageBus.Examples.SampleMessageData2

 test "this" do
    data = %{
      "id" => nil,
      "alt_id" => 12345,
      "field1" => "abc",
      "field2" => "2019-10-11T10:09:08Z",
      "field3" => "234"
    }

    changeset = SampleMessageData2.changeset(%SampleMessageData2{}, data)
    {:ok, field3_val, _} = DateTime.from_iso8601("2019-10-11 10:09:08Z")

    assert changeset.valid?
    assert changeset.changes == %{alt_id: 12345, field1: "abc", field2: field3_val, field3: 234.0}
  end
end