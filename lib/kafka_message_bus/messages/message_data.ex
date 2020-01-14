defprotocol KafkaMessageBus.Messages.MessageData do
  @moduledoc """
  The MessageData protocol supports the definition of message bodies. Structs that
  implement MessageData are used in the 'data' field of the CgMessage str ct.
  """

  @doc "
  Validates all the fields for the specified implementation of MessageData.
  "
  def validate(message_data)
end
