defmodule KafkaMessageBus.Messages.MessageData.Validator.ResponseTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.Validator.Response

  test "atom field name" do
    assert Response.ok(:field1, 42) == {:ok, %{field1: 42}}
  end

  test "string field name" do
    assert Response.ok("field1", 42) == {:ok, %{"field1" => 42}}
  end

  test "given map" do
    assert Response.ok(%{field1: 42}) == {:ok, %{field1: 42}}
  end

  test "when given no params" do
    assert Response.ok() == {:ok, %{}}
  end
end
