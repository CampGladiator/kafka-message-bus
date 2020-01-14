defmodule KafkaMessageBus.Examples.SampleMessageData do
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
  """
  require Logger
  import KafkaMessageBus.Messages.MessageData.Validator
  alias KafkaMessageBus.Messages.MessageData
  alias __MODULE__
  alias KafkaMessageBus.Utils

  defstruct id: nil,
            field1: nil,
            field2: nil,
            field3: nil

  def new(%{} = message_data) do
    {:ok,
     %SampleMessageData{
       id: Utils.safe_get(message_data, :id),
       field1: Utils.safe_get(message_data, :field1),
       field2: Utils.safe_get(message_data, :field2),
       field3: Utils.safe_get(message_data, :field3)
     }}
  end

  defimpl MessageData do
    def validate(message_data) do
      [
        &id_required/1,
        fn data -> is_string(data, :field1, :required) end,
        fn data -> is_valid_date_time_utc(data, :field2, :required) end,
        fn data -> is_integer(data, :field3, :required) end
      ]
      |> validate(message_data)
    end
  end
end
