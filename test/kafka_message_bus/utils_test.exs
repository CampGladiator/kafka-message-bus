defmodule KafkaMessageBus.UtilsTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.Messages.MessageData.MapUtil
  require Logger

  describe "to_module_short_name" do
    test "success" do
      assert Utils.to_module_short_name(KafkaMessageBus.UtilsTest) == "UtilsTest"
    end
  end

  describe "log_metadata" do
    test "setting and clearing log metadata" do
      log_metadata = %{
        "request_id" => "the_request_id",
        "resource" => "the_resource",
        "action" => "the_action",
        "source" => "the_source"
      }

      fun = fn ->
        Utils.set_log_metadata(log_metadata)
        Logger.error("Let's log an error")
      end

      assert capture_log(fun) =~ "Let's log an error"
      assert capture_log(fun) =~ "the_request_id"
      assert capture_log(fun) =~ "the_resource"
      assert capture_log(fun) =~ "the_action"
      assert capture_log(fun) =~ "the_source"

      fun2 = fn ->
        Utils.clear_log_metadata()
        Logger.error("Let's log an error")
      end

      assert capture_log(fun2) =~ "[error] Let's log an error"
      refute capture_log(fun2) =~ "the_request_id"
      refute capture_log(fun2) =~ "the_resource"
      refute capture_log(fun2) =~ "the_action"
      refute capture_log(fun2) =~ "the_source"
    end
  end

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
