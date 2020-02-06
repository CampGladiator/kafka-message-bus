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
      def map_struct(struct, %{} = message_data), do: MapUtil.deep_to_struct(struct, message_data)

      def new(nil), do: new(%{})

      defimpl MessageData do
        def validate(message_data) do
          struct_type = message_data.__struct__
          struct = struct(struct_type)
          changeset = struct_type.changeset(struct, MapUtil.deep_from_struct(message_data))

          if changeset.valid?,
            do: {:ok, apply_changes(changeset)},
            else: {:error, combine_errors(changeset)}
        end

        defp combine_errors(changeset) do
          changeset.changes
          |> Map.to_list()
          |> Enum.reduce(changeset.errors, fn error_tuple, acc ->
            acc ++ nested_errors(error_tuple)
          end)
        end

        defp nested_errors({field_name, %Ecto.Changeset{valid?: false, errors: errors}}),
          do: [{field_name, errors}]

        defp nested_errors({_field_name, _value}), do: []
      end
    end
  end
end
