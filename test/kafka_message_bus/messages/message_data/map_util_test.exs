defmodule KafkaMessageBus.MapUtilTest do
  use ExUnit.Case
  alias KafkaMessageBus.Messages.MessageData.MapUtil
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
end
