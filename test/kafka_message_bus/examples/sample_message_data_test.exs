defmodule KafkaMessageBus.Messages.MessageData.SampleMessageDataTest do
  use ExUnit.Case
  alias KafkaMessageBus.Examples.SampleMessageData

  test "using the changeset" do
    data = %{
      "id" => nil,
      "alt_id" => 12_345,
      "field1" => "abc",
      "field2" => "2019-10-11T10:09:08Z",
      "field3" => "234"
    }

    changeset = SampleMessageData.changeset(%SampleMessageData{}, data)
    {:ok, field2_val, _} = DateTime.from_iso8601("2019-10-11 10:09:08Z")

    assert changeset.valid?

    assert changeset.changes == %{
             alt_id: 12_345,
             field1: "abc",
             field2: field2_val,
             field3: 234.0
           }
  end

  test "with invalid embedded schema" do
    data = %{
      "id" => nil,
      "alt_id" => 12_345,
      "field1" => "abc",
      "field2" => "invalid",
      "field3" => "234",
      "nested_optional" => %{}
    }

    changeset = SampleMessageData.changeset(%SampleMessageData{}, data)

    refute changeset.valid?

    assert changeset.changes.nested_optional.errors == [
             id: {"can't be blank", [validation: :required]},
             field1: {"can't be blank", [validation: :required]}
           ]
  end

  test "using the changeset without required parameters" do
    changeset = SampleMessageData.changeset(%SampleMessageData{})

    refute changeset.valid?

    assert changeset.errors == [
             id: {"One of these fields must be present: [:id, :alt_id]", []},
             field1: {"can't be blank", [validation: :required]},
             field2: {"can't be blank", [validation: :required]}
           ]
  end
end
