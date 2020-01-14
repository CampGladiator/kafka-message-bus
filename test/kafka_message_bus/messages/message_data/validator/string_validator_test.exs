defmodule KafkaMessageBus.Messages.MessageData.Validator.StringValidatorTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.Validator.StringValidator

  test "ok on success" do
    message_data = %{is_a_binary: "strings are binary"}
    assert StringValidator.is_string(message_data, :is_a_binary, :required) == {:ok, %{}}
  end

  test "validation error tuple on fail" do
    message_data = %{not_a_binary_field: false}

    assert StringValidator.is_string(message_data, :not_a_binary_field, :required) ==
             {:error, {:not_a_string, :not_a_binary_field, false}}
  end

  test "nil cases error when field is required" do
    message_data = %{not_a_binary_field: nil}

    assert StringValidator.is_string(message_data, :not_a_binary_field, :required) ==
             {:error, {:field_required, :not_a_binary_field, nil}}
  end

  test "should support checking valid values (required)" do
    valid_values = ["val1", "val2"]

    message_data = %{is_a_binary: "val2"}

    assert StringValidator.is_string(message_data, :is_a_binary, :required, valid_values) ==
             {:ok, %{}}

    message_data2 = %{is_a_binary: "strings are binary"}

    assert StringValidator.is_string(message_data2, :is_a_binary, :required, valid_values) ==
             {:error, {:invalid_field_value, :is_a_binary, "strings are binary"}}
  end

  test "should support checking valid values (not required)" do
    valid_values = ["val1", "val2"]

    message_data = %{is_a_binary: "val2"}

    assert StringValidator.is_string(message_data, :is_a_binary, :not_required, valid_values) ==
             {:ok, %{}}

    message_data2 = %{is_a_binary: "strings are binary"}

    assert StringValidator.is_string(message_data2, :is_a_binary, :not_required, valid_values) ==
             {:error, {:invalid_field_value, :is_a_binary, "strings are binary"}}
  end
end
