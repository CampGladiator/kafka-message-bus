defmodule KafkaMessageBus.Messages.MessageData.Validator.RequiredValidatorTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.Validator.RequiredValidator

  test "ok if one id is found" do
    message_data = %{nation_id: "123"}
    {:ok, validated_message_data} = RequiredValidator.required(message_data, [:id, :nation_id])
    assert validated_message_data == %{}
  end

  test "error if not found in map" do
    {:error, error_data} = RequiredValidator.required(%{}, :id)
    {err_msg, field_name, field_value} = error_data
    assert err_msg == :field_required
    assert field_name == :id
    refute field_value
  end

  test "handles error on multiple id fields" do
    {:error, error_data} = RequiredValidator.required(%{}, [:id, :nation_id])
    {err_msg, field_name, field_value} = error_data
    assert err_msg == :field_required
    assert field_name == [:id, :nation_id]
    refute field_value
  end

  test "error if list is empty" do
    {:error, error_data} = RequiredValidator.required(%{}, [])
    assert error_data == :field_missing
  end

  test "can call require with nested validator" do
    validation_func = fn _message_data, _field_name -> {:ok, :inside} end
    message_data = %{nation_id: "123"}

    {:ok, validated_message_data} =
      RequiredValidator.required(message_data, [:id, :nation_id], validation_func)

    assert validated_message_data == :inside
  end

  test "bypasses inner validator if error missing and required" do
    validation_func = fn _message_data, _field_name -> {:error, :bad_things} end

    {:error, {err_msg, field_name, field_value}} =
      RequiredValidator.required(%{}, [:id, :nation_id], validation_func)

    assert err_msg == :field_required
    assert field_name == [:id, :nation_id]
    refute field_value
  end
end
