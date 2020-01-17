defmodule KafkaMessageBus.MessageDataValidatorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.MessageDataValidator

  test "validates and returns ok with suggested changes" do
    message_data = %{
      "id" => "ID_1",
      "field1" => "the text",
      "field2" => "2019-12-19 19:22:26.779098Z",
      "field3" => "42"
    }

    resource = "sample_resource"
    action = "sample_action"
    message = %{"data" => message_data, "action" => action, "resource" => resource}

    fun = fn ->
      {:ok, validated_message} = MessageDataValidator.validate(message)

      assert validated_message.id == "ID_1"
      assert validated_message.field1 == "the text"
      {:ok, datetime1, _} = DateTime.from_iso8601("2019-12-19 19:22:26.779098Z")
      assert validated_message.field2 == datetime1
      assert validated_message.field3 == 42
    end

    assert capture_log(fun) =~ "[info]  creating for sample_resource and sample_action:"
  end

  test "passes errors through" do
    message_data = %{
      "id" => "ID_1",
      "field1" => "the text",
      "field2" => "INVALID DATA",
      "field3" => 42
    }

    resource = "sample_resource"
    action = "sample_action"
    message = %{"data" => message_data, "action" => action, "resource" => resource}

    fun = fn ->
      {:error, err_list} = MessageDataValidator.validate(message)

      assert Enum.count(err_list) == 1
      assert Enum.at(err_list, 0) == {:invalid_datetime, :field2, "INVALID DATA"}
    end

    assert capture_log(fun) =~
             "[debug] Error encountered while parsing from_iso8601: :invalid_format"
  end

  test "validate/1 return error is map is missing any expected fields" do
    message_data = %{
      "id" => "ID_1",
      "field1" => "the text",
      "field2" => "INVALID DATA",
      "field3" => "USER_ID_1"
    }

    action = "sample_action"
    message = %{"data" => message_data, "action" => action}

    {:error, err_msg} = MessageDataValidator.validate(message)

    assert err_msg =~ "Could not process message:"
  end
end
