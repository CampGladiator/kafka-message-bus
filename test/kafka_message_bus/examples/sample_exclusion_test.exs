defmodule KafkaMessageBus.Messages.MessageData.SampleExclusionTest do
  use ExUnit.Case
  alias KafkaMessageBus.Examples.SampleExclusion
  alias KafkaMessageBus.Messages.MessageData

  test "can be used by factory" do
    {:ok, exclusion} = SampleExclusion.new(%{})
    assert exclusion == %SampleExclusion{field1: nil, id: nil}
  end

  test "can be validated" do
    {:ok, exclusion} = SampleExclusion.new(%{})

    assert MessageData.validate(exclusion) ==
             {:error,
              [
                id: {"can't be blank", [validation: :required]},
                field1: {"can't be blank", [validation: :required]}
              ]}
  end
end
