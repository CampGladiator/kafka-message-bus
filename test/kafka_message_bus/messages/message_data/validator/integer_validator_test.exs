defmodule KafkaMessageBus.Messages.MessageData.Validator.IntegerValidatorTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.Validator.IntegerValidator

  test "ok on success" do
    message_data = %{the_field: 42}
    assert IntegerValidator.is_integer(message_data, :the_field, :required) == {:ok, %{}}
  end

  test "integers are numbers too" do
    message_data = %{the_field: "42"}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:ok, %{the_field: 42}}
  end

  test "floats without remainders will be parsed as integers" do
    message_data = %{the_field: 42.0}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:ok, %{the_field: 42}}
  end

  test "float strings without remainders will be parsed as integers" do
    message_data = %{the_field: "42.0"}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:ok, %{the_field: 42}}
  end

  test "float strings with remainders will result in an error" do
    message_data = %{the_field: "42.5"}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:error, {:not_an_integer, :the_field, "42.5"}}
  end

  test "floats with remainders will result in an error" do
    message_data = %{the_field: 42.5}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:error, {:not_an_integer, :the_field, 42.5}}
  end

  test "validation error tuple on fail" do
    message_data = %{the_field: false}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:error, {:not_an_integer, :the_field, false}}
  end

  test "nil is not is_integer" do
    message_data = %{the_field: nil}

    assert IntegerValidator.is_integer(message_data, :the_field, :required) ==
             {:error, {:field_required, :the_field, nil}}
  end

  test "nil returns default if not required" do
    message_data = %{the_field: nil}

    assert IntegerValidator.is_integer(message_data, :the_field, :not_required) ==
             {:ok, %{the_field: 0}}
  end
end
