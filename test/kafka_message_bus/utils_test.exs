defmodule KafkaMessageBus.UtilsTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.Utils
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
end
