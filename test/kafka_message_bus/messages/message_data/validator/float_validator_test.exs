defmodule KafkaMessageBus.Messages.MessageData.Validator.FloatValidatorTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.Validator.FloatValidator

  test "integers are floats too" do
    message_data = %{the_field: 42}

    assert FloatValidator.is_float(message_data, :the_field, :required) ==
             {:ok, %{the_field: 42.0}}
  end

  test "ok on success" do
    message_data = %{the_field: 42.0}
    assert FloatValidator.is_float(message_data, :the_field, :required) == {:ok, %{}}
  end

  test "ok on success with string" do
    message_data = %{the_field: "42.0"}

    assert FloatValidator.is_float(message_data, :the_field, :required) ==
             {:ok, %{the_field: 42.0}}
  end

  test "ok on success as integer with string" do
    message_data = %{the_field: "42"}

    assert FloatValidator.is_float(message_data, :the_field, :required) ==
             {:ok, %{the_field: 42.0}}
  end

  test "validation error tuple on fail" do
    message_data = %{the_field: false}

    assert FloatValidator.is_float(message_data, :the_field, :required) ==
             {:error, {:not_a_float, :the_field, false}}
  end

  test "nil is not is_float" do
    message_data = %{the_field: nil}

    assert FloatValidator.is_float(message_data, :the_field, :required) ==
             {:error, {:field_required, :the_field, nil}}
  end

  test "nil returns default if not required" do
    message_data = %{the_field: nil}

    assert FloatValidator.is_float(message_data, :the_field, :not_required) ==
             {:ok, %{the_field: 0.0}}
  end
end
