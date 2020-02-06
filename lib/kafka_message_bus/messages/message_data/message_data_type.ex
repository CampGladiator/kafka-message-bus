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
        mapped =
          Enum.reduce(Map.to_list(struct), struct, fn {key, _}, acc ->
            case MapUtil.safe_get(message_data, key) do
              value when key in [:__meta__, :__struct__] ->
                acc

              value when is_map(value) === true ->
                {:ok, struct_value} =
                  Map.get(struct, key)
                  |> map_struct(value)

                %{acc | key => struct_value}

              value ->
                %{acc | key => value}
            end
          end)

        {:ok, mapped}
      end

      @doc """
      This function is used to convert the stuct definition of message data
      to a map which is needed for changeset validation.
      """
      def struct_map(struct) do
        struct
        |> Map.from_struct()
        |> Map.to_list()
        |> Enum.reduce(Map.from_struct(struct), fn {key, value}, acc ->
          case value do
            value when is_map(value) === true ->
              %{acc | key => Map.from_struct(value)}

            value ->
              %{acc | key => value}
          end
        end)
      end

      def new(nil), do: new(%{})

      defimpl MessageData do
        def validate(message_data) do
          struct_type = message_data.__struct__
          struct = struct(struct_type)
          changeset = struct_type.changeset(struct, Map.from_struct(message_data))

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
