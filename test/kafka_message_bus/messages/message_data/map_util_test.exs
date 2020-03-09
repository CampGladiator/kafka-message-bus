defmodule KafkaMessageBus.MapUtilTest do
  import ExUnit.CaptureLog
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.MapUtil
  alias KafkaMessageBus.Examples.{SampleMessageData, SampleExclusion}
  require Logger

  describe "safe_get" do
    test "gets atom key by atom" do
      id = MapUtil.safe_get(%{test_id: 1234}, :test_id)
      assert id == 1234
    end

    test "gets string key by atom" do
      id = MapUtil.safe_get(%{"test_id" => 1234}, :test_id)
      assert id == 1234
    end

    test "gets atom key by string" do
      id = MapUtil.safe_get(%{test_id: 1234}, "test_id")
      assert id == 1234
    end

    test "returns error when field_name string is unrecognized as an existing atom" do
      expected_err_msg =
        "Failed to convert field_name 'unk_key' to an existing atom. ERR: %ArgumentError{message: \"argument error\"}"

      fun = fn ->
        {:error, err_msg} = MapUtil.safe_get(%{test_id: 1234}, "unk_key")
        assert err_msg == expected_err_msg
      end

      assert capture_log(fun) =~ "[warn]  #{expected_err_msg}"
    end

    test "gets string key by string" do
      id = MapUtil.safe_get(%{"test_id" => 1234}, "test_id")
      assert id == 1234
    end

    test "returns nil if not found" do
      id = MapUtil.safe_get(%{}, "test_id")
      assert is_nil(id)
    end

    test "trying to get from types other than maps results in an error" do
      assert MapUtil.safe_get("not-a-map", "test_id") ==
               {:error,
                "Unexpected param encountered. map: \"not-a-map\", field_name: \"test_id\""}
    end
  end

  describe "deep_to_struct" do
    test "should not accept nil for struct" do
      message_struct = %{
        id: "ID_1",
        field1: "the text",
        field2: "2019-12-19 19:22:26.779098Z",
        field3: "42",
        nested_optional: %{
          field1: "this field"
        }
      }

      {:ok, map} =
        MapUtil.deep_to_struct(
          %SampleMessageData{nested_optional: nil},
          message_struct
        )

      refute map.nested_optional
    end

    test "validate deep_to_struct converts properly" do
      message_struct = %{
        id: "ID_1",
        field1: "the text",
        field2: "2019-12-19 19:22:26.779098Z",
        field3: "42",
        nested_optional: %{
          field1: "this field"
        }
      }

      map =
        MapUtil.deep_to_struct(
          %SampleMessageData{nested_optional: %SampleExclusion{}},
          message_struct
        )

      assert map ==
               {:ok,
                %SampleMessageData{
                  id: "ID_1",
                  field1: "the text",
                  field2: "2019-12-19 19:22:26.779098Z",
                  field3: "42",
                  alt_id: nil,
                  nested_optional: %SampleExclusion{
                    field1: "this field",
                    id: nil
                  }
                }}
    end

    test "should ignore Ecto.Association.NotLoaded" do
      message_struct = %{
        id: "ID_1",
        field1: "the text",
        field2: "2019-12-19 19:22:26.779098Z",
        field3: struct(Ecto.Association.NotLoaded, %{})
      }

      {:ok, map} =
        MapUtil.deep_to_struct(
          %SampleMessageData{nested_optional: %SampleExclusion{}},
          message_struct
        )

      refute map.field3
    end
  end

  describe "deep_from_struct" do
    test "validate deep_from_struct converts properly" do
      message_struct = %SampleMessageData{
        id: "ID_1",
        field1: "the text",
        field2: "2019-12-19 19:22:26.779098Z",
        field3: "42",
        nested_optional: %SampleExclusion{
          field1: "this field"
        }
      }

      map = MapUtil.deep_from_struct(message_struct)

      assert map ==
               %{
                 id: "ID_1",
                 field1: "the text",
                 field2: "2019-12-19 19:22:26.779098Z",
                 field3: "42",
                 alt_id: nil,
                 nested_optional: %{
                   field1: "this field",
                   id: nil
                 }
               }
    end
  end
end
