defmodule KafkaMessageBus.Messages.MessageData.FactoryTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias KafkaMessageBus.Examples.SampleMessageData
  alias KafkaMessageBus.Messages.MessageData.Factory

  describe "message_contract_exclusions" do
    test "default test context has no exclusions" do
      result = Factory.get_message_contract_exclusions()
      assert result == :none
    end

    test ":all exclusions returns message to bypass message enforcement" do
      {:ok, sample_data} = Factory.create(%{}, "sample_resource", "sample_action", :all)
      assert sample_data == :message_contract_excluded
    end

    test "exclusions list returns message to bypass message enforcement on factory match" do
      fun = fn ->
        {:ok, sample_data} =
          Factory.create(%{}, "sample_resource", "sample_action", [SampleMessageData])

        assert sample_data == :message_contract_excluded
      end

      assert capture_log(fun) =~ "[info]  Creating for sample_resource and sample_action: %{}"
    end

    test "missing new/1 function defined" do
      fun = fn ->
        assert_raise UndefinedFunctionError,
                     "function KafkaMessageBus.Messages.MessageData.Factory.on_create/3 is undefined or private",
                     fn ->
                       Factory.create(%{}, "sample_resource", "sample_action", [], Factory)
                     end
      end

      assert capture_log(fun) =~ "[error] Missing on_create/3 function in factory_implementation: Elixir.KafkaMessageBus.Messages.MessageData.Factory"
    end

    test "should return error if invalid input provided" do
      fun = fn ->
        {:error, err_msg} = Factory.create(%{}, "sample_resource", "sample_action", "not valid")
        assert err_msg == :unexpected_message_contract_exclusions
      end

      assert capture_log(fun) =~
               "[error] Unexpected value for message_contract_exclusions: \"not valid\""
    end
  end

  test "error on unrecognized message data type" do
    fun = fn ->
      {:error, err_msg} = Factory.create("bad-data", "resource", "action")
      assert err_msg == :unrecognized_message_data_type
    end

    assert capture_log(fun) =~
             "Encountered unrecognized message type for resource: resource, action: action. \"bad-data\""
  end
end
