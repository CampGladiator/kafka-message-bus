defmodule KafkaMessageBus.Messages.MessageData.Validator.BooleanValidatorTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.Validator.BooleanValidator

  test "ok on success" do
    message_data = %{is_a_bool: true}
    assert BooleanValidator.is_boolean(message_data, :is_a_bool, :required) == {:ok, %{}}
  end

  test "should parse string bools" do
    assert BooleanValidator.is_boolean(%{is_a_string_bool: "true"}, :is_a_string_bool, :required) ==
             {:ok, %{is_a_string_bool: true}}

    assert BooleanValidator.is_boolean(%{is_a_string_bool: "false"}, :is_a_string_bool, :required) ==
             {:ok, %{is_a_string_bool: false}}
  end

  test "validation error tuple on fail" do
    message_data = %{not_a_boolean_field: "not a bool"}

    assert BooleanValidator.is_boolean(message_data, :not_a_boolean_field, :required) ==
             {:error, {:not_a_boolean, :not_a_boolean_field, "not a bool"}}
  end

  test "nil is not boolean" do
    message_data = %{not_a_boolean_field: nil}

    assert BooleanValidator.is_boolean(message_data, :not_a_boolean_field, :required) ==
             {:error, {:field_required, :not_a_boolean_field, nil}}
  end

  test "suggests false is field is not required and value is nil" do
    message_data = %{not_a_boolean_field: nil}

    assert BooleanValidator.is_boolean(message_data, :not_a_boolean_field, :not_required) ==
             {:ok, %{not_a_boolean_field: false}}
  end
end
