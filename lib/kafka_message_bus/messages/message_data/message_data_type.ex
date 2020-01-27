defmodule KafkaMessageBus.Messages.MessageData.MessageDataType do
  @moduledoc """
  This is the base module for all message data type definition. A
  message data type is the type that represents the contents of the
  'data' field on the kafka message.
  """

  defmacro __using__(_opts) do
    quote do
      import KafkaMessageBus.Messages.MessageData.Validator
      alias KafkaMessageBus.Messages.MessageData
      alias KafkaMessageBus.Messages.MessageData.MapUtil
      use Ecto.Schema
      import Ecto.Changeset

      @doc """
      This function is used to facilitate the definition of message data
      type's new/1 (factory) functions.
      """
      def map_struct(struct, %{} = message_data) do
        mapped = Enum.reduce Map.to_list(struct), struct, fn {key, _}, acc ->
          case MapUtil.safe_get(message_data, key) do
            value when key in [:__meta__, :__struct__] ->
              acc
            value ->
              %{acc | key => value}
          end
        end

        {:ok, mapped}
      end

      defimpl MessageData do
        def validate(message_data) do
          struct_type = message_data.__struct__
          struct = struct(struct_type)
          changeset = struct_type.changeset(struct, Map.from_struct(message_data))

          if changeset.valid?,
             do: {:ok, changeset.changes},
             else: {:error, changeset.errors}
        end
      end
    end
  end
end
