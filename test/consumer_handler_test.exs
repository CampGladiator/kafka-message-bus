defmodule KafkaMessageBus.ConsumerHandlerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.ConsumerHandler

  test "valid message_data" do
    message_data = %{
      id: "ID_1",
      field1: "the text",
      field2: "2019-12-19 19:22:26.779098Z",
      field3: "42"
    }

    resource = "sample_resource"
    action = "sample_action"
    message = %{"data" => message_data, "action" => action, "resource" => resource}

    assert capture_log(fn ->
             assert ConsumerHandler.perform(OkConsumer, message) == :ok
           end) =~ "Running OkConsumer message handler"
  end

  test "will convert module to atom if provided as string" do
    message_data = %{
      "id" => "ID_1",
      "field1" => "the text",
      "field2" => "2019-12-19 19:22:26.779098Z",
      "field3" => 42
    }

    resource = "sample_resource"
    action = "sample_action"
    message = %{"data" => message_data, "action" => action, "resource" => resource}

    assert capture_log(fn ->
             assert ConsumerHandler.perform("Elixir.OkConsumer", message) == :ok
           end) =~ "Running OkConsumer message handler"
  end

  test "executes without validation if exclusion message gets passed to message_data_handler" do
    message = {:ok, :message_contract_excluded}

    assert capture_log(fn ->
             ConsumerHandler.perform(OkConsumer, message)
           end) =~ "[info]  Message contract (consume) excluded"
  end

  test "invalid message_data" do
    message_data = %{
      "id" => "ID_1",
      "field1" => "the text",
      "field2" => "invalid_data",
      "field3" => "42"
    }

    resource = "sample_resource"
    action = "sample_action"
    message = %{"data" => message_data, "action" => action, "resource" => resource}

    fun = fn ->
      {:error, err_list} = ConsumerHandler.perform(OkConsumer, message)
      assert err_list == [{:field2, {"is invalid", [type: :utc_datetime, validation: :cast]}}]
    end

    assert capture_log(fun) =~
             "Unexpected response encountered when validating consumer message data"
  end

  test "unrecognized action will attempt to process anyway" do
    message_data = %{
      "id" => "NOTE_ID_1",
      "field1" => "note text",
      "field2" => "2019-12-19 19:22:26.779098Z",
      "field3" => "42"
    }

    resource = "sample_resource"
    message = %{"data" => message_data, "action" => "not an action", "resource" => resource}

    fun = fn ->
      assert ConsumerHandler.perform(OkConsumer, message) == :ok
    end

    assert capture_log(fun) =~ "Encountered unrecognized message type for resource"
  end
end

defmodule SampleServiceMsg do
  def consumer do
    quote do
      @behaviour KafkaMessageBus.Consumer
      require Logger
    end
  end

  defmacro __using__(which) when is_atom(which), do: apply(__MODULE__, which, [])
end

defmodule OkConsumer do
  use SampleServiceMsg, :consumer

  def process(_message_data) do
    :ok
  end
end

defmodule ExcludedContractConsumer do
  use SampleServiceMsg, :consumer

  def process(_message_data) do
    {:ok, :message_contract_excluded}
  end
end
