defmodule KafkaMessageBus.Examples.SampleMessageData do
  @moduledoc """
  This is an example of how validator structs should be written.

  The first step to defining a validator struct is to use the MessageDataType
  module as follows:
  use KafkaMessageBus.Messages.MessageData.MessageDataType

  Structure:
  Validator structs are written as Ecto embedded_schemas. The user will
  define the schema using Ecto and will thereby specify the types and
  default values through the Ecto schema.

  Factory function:
  Each message data struct will provide a new/1 function. One can create
  this function by copy/pasting the following line into the module
  definition:
  def new(%{} = message_data), do: map_struct(%__MODULE__{}, message_data)

  Validate function:
  Validation rules for each validation struct will be implemented by
  defining the schema's changeset/2 function. The additional function,
  validate_required_inclusion/2, is used to ensure that one of n fields
  is provided with the message data.
  """
  use KafkaMessageBus.Messages.MessageData.MessageDataType

  @primary_key {:id, :string, []}
  embedded_schema do
    field :alt_id, :integer
    field :field1, :string
    field :field2, :utc_datetime
    field :field3, :float
  end

  @required_params [:field1, :field2]
  @optional_params [:id, :alt_id, :field3]

  def changeset(%__MODULE__{} = message_data, attrs \\ %{}) do
    message_data
    |> cast(attrs, @required_params ++ @optional_params)
    |> validate_required(@required_params)
    |> validate_required_inclusion([:id , :alt_id])
  end

  def new(%{} = message_data), do: map_struct(%__MODULE__{}, message_data)
end
