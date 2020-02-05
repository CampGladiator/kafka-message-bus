defmodule KafkaMessageBus.Messages.MessageData.Factory do
  @moduledoc """
  A set of functions that take resource, action, and data as parameters and returns an
  instance of the appropriate message data struct. Each message data type will support a
  function new/1 that is a struct representation of the map data that it received. These
  new/1 functions do not alter or validate the data field values.
  """

  alias KafkaMessageBus.Config
  require Logger

  @doc """
  This function is the entry point for the Factory module. It's parameters include the message data,
  the message resource, and the message action. The resource and action are used to determine the
  appropriate message_data struct. The parameter 'data' will be passed to that struct's new/1 function.

  Message contract exclusions are optional and will be pulled from the modules configuration by default.
  These possible message_contract_exclusions can be passed to create/4:
  :none - This means that there are no exclusions.
  :all - This means that all validation will be excluded.
  [exclusions] - This is a list of message_data structs that should be excluded from validation.
  * anything else will be treated as an error.
  """
  def create(
        data,
        resource,
        action,
        message_contract_exclusions \\ get_message_contract_exclusions(),
        factory_implementation \\ get_factory_implementation()
      ) do
    case message_contract_exclusions do
      :none ->
        on_create(data, resource, action, factory_implementation)

      :all ->
        {:ok, :message_contract_excluded}

      exclusions when is_list(exclusions) ->
        on_create(data, resource, action, exclusions, factory_implementation)

      err ->
        Logger.error(fn ->
          "Unexpected value for message_contract_exclusions: #{inspect(err)}"
        end)

        {:error, :unexpected_message_contract_exclusions}
    end
  end

  defp on_create(_data, _resource, _action, _exclusions, nil),
    do: {:error, :missing_factory_implementation}

  defp on_create(data, resource, action, exclusions, factory_implementation)
       when is_list(exclusions) do
    case on_create(data, resource, action, factory_implementation) do
      {:ok, data} ->
        if data.__struct__ in exclusions,
          do: {:ok, :message_contract_excluded},
          else: {:ok, data}

      {:error, :unrecognized_message_data_type} ->
        {:error, :unrecognized_message_data_type}
    end
  end

  defp on_create(_data, _resource, _action, nil), do: {:error, :missing_factory_implementation}

  defp on_create(data, resource, action, factory_implementation) do
    factory_implementation.on_create(data, resource, action)
  rescue
    err in UndefinedFunctionError ->
      case err.function do
        :on_create ->
          err_message = "Missing on_create/3 function in factory_implementation: #{err.module}"
          Logger.error(fn -> err_message <> ", error: #{inspect(err)}" end)

          reraise err, __STACKTRACE__
      end
  end

  def get_message_contract_exclusions do
    case Config.message_contracts!()[:exclusions] do
      nil -> :all
      found -> found
    end
  end

  def get_factory_implementation,
    do: Config.message_contracts!()[:message_data_factory_implementation]
end
