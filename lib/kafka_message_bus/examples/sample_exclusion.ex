defmodule KafkaMessageBus.Examples.SampleExclusion do
  @moduledoc """
  This is used to show how exclusions work.
  """
  use KafkaMessageBus.Messages.MessageData.MessageDataType

  @primary_key {:id, :string, []}
  embedded_schema do
    field(:field1, :string)
  end

  @required_params [:id, :field1]

  def changeset(%__MODULE__{} = message_data, attrs \\ %{}) do
    message_data
    |> cast(attrs, @required_params)
    |> validate_required(@required_params)
  end

  def new(%{} = message_data), do: map_struct(%__MODULE__{}, message_data)
end
