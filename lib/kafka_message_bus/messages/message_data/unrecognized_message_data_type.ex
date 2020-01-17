defmodule KafkaMessageBus.Messages.MessageData.UnrecognizedMessageDataType do
  @moduledoc """
  This is the module that handles unrecognized messages (based on resource and action).
  """
  def on_create do
    quote do
      def on_create(data, resource, action) when is_binary(resource) and is_binary(action) do
        fn ->
          "Encountered unrecognized message type for resource: #{resource}, action: #{action}. #{
            inspect(data)
          }"
        end
        |> Logger.warn()

        {:error, :unrecognized_message_data_type}
      end
    end
  end

  defmacro __using__(which) when is_atom(which), do: apply(__MODULE__, which, [])
end
