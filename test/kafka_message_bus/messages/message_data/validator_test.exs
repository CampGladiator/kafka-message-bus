defmodule KafkaMessageBus.Messages.MessageData.ValidatorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.Messages.MessageData.Validator

  describe "validate" do
    setup do
      message_data = %{
        int_val: "1234",
        int_val2: 2345,
        int_val3: "3456",
        missing_val: nil,
        string_val: "this-is-a-name",
        datetime: "2019-10-11T10:09:08Z"
      }

      {:ok, message_data: message_data}
    end

    test "returns empty map if no validation change suggestions encountered", %{
      message_data: message_data
    } do
      {:ok, validated_data} = Validator.do_validate([], message_data)

      assert validated_data == %{}
    end

#    test "returns ok if all validations pass without change suggestions", %{
#      message_data: message_data
#    } do
#      {:ok, validated_message_data} =
#        [
#          fn data -> Validator.is_integer(data, :int_val2, :required) end
#        ]
#        |> Validator.do_validate(message_data)
#
#      assert validated_message_data == %{}
#    end

#    test "returns ok with multiple change suggestions", %{message_data: message_data} do
#      {:ok, validated_message_data} =
#        [
#          fn data -> Validator.is_integer(data, :int_val, :required) end,
#          fn data -> Validator.is_integer(data, :int_val2, :required) end,
#          fn data -> Validator.is_integer(data, :int_val3, :required) end
#        ]
#        |> Validator.do_validate(message_data)
#
#      assert validated_message_data == %{int_val: 1234, int_val3: 3456}
#    end

    test "unexpected errors pass through", %{message_data: message_data} do
      fun = fn ->
        {:error, err_msg} =
          [
            fn _data -> {:error, :something_unexpected_happened} end
          ]
          |> Validator.do_validate(message_data)

        assert err_msg == :something_unexpected_happened
      end

      assert capture_log(fun) =~
               "[info]  Failure encountered while validating: {:error, :something_unexpected_happened}"
    end

#    test "returns error tuple if any validations fail" do
#      {:error, validated_message_data} =
#        Validator.validate(
#          [fn data -> Validator.is_integer(data, :missing_val, :required) end],
#          %{id: nil}
#        )
#
#      assert validated_message_data == [{:field_required, :missing_val, nil}]
#    end
  end

  defp validator(message_data) do
    [
      fn data -> Validator.is_integer(data, :int1, :required) end,
      fn data -> Validator.is_integer(data, :int2, :required) end,
      &nested_validator/1
    ]
    |> Validator.do_validate(message_data)
  end

  defp nested_validator(message_data) do
    [
      fn data -> Validator.is_integer(data, :nest_int1, :required) end,
      fn data -> Validator.is_integer(data, :nest_int2, :required) end
    ]
    |> Validator.nested_validate(message_data, :nested)
  end

  describe "nested validate" do
    setup do
      message_data = %{
        int1: 1,
        int2: 2,
        nested: %{
          nest_int1: 3,
          nest_int2: 4
        }
      }

      {:ok, message_data: message_data}
    end

    test "when all is valid", %{message_data: message_data} do
      assert validator(message_data) == {:ok, %{}}
    end

    test "should return both base and nested change suggestions", %{message_data: message_data} do
      new_nested = %{message_data[:nested] | nest_int2: "40"}
      new_message_data = %{message_data | int2: "20", nested: new_nested}
      assert validator(new_message_data) == {:ok, %{int2: 20, nested: %{nest_int2: 40}}}
    end
  end

  describe "apply_change_suggestions" do
    setup do
      message_data = %{
        int1: 1,
        int2: "20",
        nested: %{
          nest_int1: 3,
          nest_int2: "40"
        }
      }

      {:ok, message_data: message_data}
    end

    test "should apply suggestion changes", %{message_data: message_data} do
      validation_result = validator(message_data)
      assert validation_result == {:ok, %{int2: 20, nested: %{nest_int2: 40}}}

      {:ok, with_applied_changes} =
        Validator.apply_change_suggestions(validation_result, message_data)

      assert with_applied_changes == %{
               int1: 1,
               int2: 20,
               nested: %{
                 nest_int1: 3,
                 nest_int2: 40
               }
             }
    end

    test "should not parse structs as nested maps", %{message_data: message_data} do
      {:ok, datetime1, _} = DateTime.from_iso8601("2020-01-23 23:50:07Z")
      validation_result = {:ok, %{date1: datetime1, int2: 20, nested: %{nest_int2: 40}}}

      {:ok, with_applied_changes} =
        Validator.apply_change_suggestions(validation_result, message_data)

      assert with_applied_changes == %{
               int1: 1,
               int2: 20,
               nested: %{nest_int1: 3, nest_int2: 40},
               date1: datetime1
             }
    end

    test "should return unchanged message data if no suggested changes" do
      message_data = %{
        int1: 1,
        int2: 2,
        nested: %{
          nest_int1: 3,
          nest_int2: 4
        }
      }

      validation_result = validator(message_data)
      assert validation_result == {:ok, %{}}

      {:ok, with_applied_changes} =
        Validator.apply_change_suggestions(validation_result, message_data)

      assert with_applied_changes == %{
               int1: 1,
               int2: 2,
               nested: %{
                 nest_int1: 3,
                 nest_int2: 4
               }
             }
    end

    test "passes errors through", %{message_data: message_data} do
      err = {:error, "error data"}

      assert Validator.apply_change_suggestions(err, message_data) == err
    end
  end

  describe "execute_validation when validation_ok" do
    test "unhandled errors pass through" do
      message_data = %{data: "this is the data"}
      validation_function = fn _x -> {:ok, message_data} end

      result =
        Validator.execute_validation(
          validation_function,
          {:error, :unhandled_error},
          message_data
        )

      assert result == {:error, :unhandled_error}
    end

    test "pass through ok when no errors have been encountered" do
      message_data = %{data: "this is the data"}
      validation_function = fn _x -> {:ok, message_data} end

      result =
        Validator.execute_validation(validation_function, {:ok, message_data}, message_data)

      assert result == {:ok, %{data: "this is the data"}}
    end

    test "errors list pass through when validation errors have been encountered" do
      message_data = %{data: "this is the data"}
      validation_function = fn _x -> {:ok, message_data} end

      result =
        Validator.execute_validation(
          validation_function,
          [{:err_msg, :field_name, :field_value}],
          message_data
        )

      assert result == [{:err_msg, :field_name, :field_value}]
    end
  end

  describe "execute_validation when add_validation_error" do
    test "if list already exists, append to existing error list" do
      message_data = %{data: "this is the data"}
      validation_function = fn _x -> {:error, {:err_msg, :field_name, :field_value}} end

      result =
        Validator.execute_validation(
          validation_function,
          [{:err_msg, :field_name, :field_value}],
          message_data
        )

      assert result == [
               {:err_msg, :field_name, :field_value},
               {:err_msg, :field_name, :field_value}
             ]
    end

    test "if no list exists, return error tuple in list" do
      message_data = %{data: "this is the data"}
      validation_function = fn _x -> {:error, {:err_msg, :field_name, :field_value}} end
      result = Validator.execute_validation(validation_function, nil, message_data)
      assert result == [{:err_msg, :field_name, :field_value}]
    end

    test "pass through unhandled errors" do
      message_data = %{data: "this is the data"}
      validation_function = fn _x -> {:error, :something_bad_happened} end

      fun = fn ->
        result = Validator.execute_validation(validation_function, nil, message_data)
        assert result == {:error, :something_bad_happened}
      end

      assert capture_log(fun) =~
               "Failure encountered while validating: {:error, :something_bad_happened}"
    end
  end

  describe "date time validations" do
    test "is_valid_date_time_utc" do
      {:ok, datetime1, _} = DateTime.from_iso8601("2019-11-19T19:22:26.779098Z")
      message_data = %{datetime: datetime1}

      {:ok, validated_message_data} =
        Validator.is_valid_date_time_utc(message_data, :datetime, :required)

      assert validated_message_data == %{datetime: datetime1}
    end

    test "is_valid_date_utc" do
      message_data = %{datetime: "2019-11-19"}

      {:ok, validated_message_data} =
        Validator.is_valid_date_utc(message_data, :datetime, :not_required)

      assert validated_message_data == %{datetime: ~D[2019-11-19]}
    end

    test "is_valid_time_utc" do
      datetime_string = "23:50:07"
      message_data = %{thetime: datetime_string}

      {:ok, validated_message_data} =
        Validator.is_valid_time_utc(message_data, :thetime, :not_required)

      assert validated_message_data == %{thetime: ~T[23:50:07]}
    end
  end

  describe "required" do
    test "ok if one id is found" do
      message_data = %{nation_id: "123"}
      {:ok, validated_message_data} = Validator.required(message_data, [:id, :nation_id])
      assert validated_message_data == %{}
    end

    test "default looks for 'id' or 'nation_id'" do
      message_data = %{id: "123", other_field: "bob"}
      assert {:ok, %{}} = Validator.id_required(message_data)

      message_data2 = %{nation_id: 123, other_field: "bob"}
      assert {:ok, %{}} = Validator.id_required(message_data2)
    end

    test "can call require with nested validator" do
      validation_func = fn _message_data, _field_name -> {:ok, :inside} end
      message_data = %{nation_id: "123"}

      {:ok, validated_message_data} =
        Validator.required(message_data, [:id, :nation_id], validation_func)

      assert validated_message_data == :inside
    end
  end
end
