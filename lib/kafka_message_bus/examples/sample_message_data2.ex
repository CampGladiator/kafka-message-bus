defmodule KafkaMessageBus.Examples.SampleMessageData2 do
  @moduledoc """
  This is an example of how validator structs should be written.

  Structure:
  These structs will have a defstruct with a list of all the fields
  you need to validate on given message data. Each of these fields
  will be initialized to nil.

  Factory function:
  Each message data struct will provide a new/1 function. This
  function takes a message data map the is the 'data' field on the
  kafka message bus message. The new/1 method needs to be able
  to handle maps that use either strings or atoms as keys. Producers
  will pass maps that are keyed using atoms. Consumers will receive
  maps that are keyed using strings. The factory function will return
  an ok tuple with a new instance of this struct containing the unvalidated
  field values found in the map parameter.

  Validate function:
  Each message data struct will implement MessageData's validate/1
  function. The only contents of this function should be a list of
  field validators piped into MessageData's validate/2 function.
  The validation rules for each message data type are these validation
  function lists.

  https://stackoverflow.com/questions/40720942/is-it-possible-to-use-elixir-changesets-validations-without-using-models
  """
  use KafkaMessageBus.Messages.MessageData.MessageDataType
  alias __MODULE__

  @primary_key {:id, :string, []}
  schema "" do
    field :alt_id, :integer, virtual: true
    field :field1, :string, virtual: true
    field :field2, :utc_datetime, virtual: true
    field :field3, :float, virtual: true
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
