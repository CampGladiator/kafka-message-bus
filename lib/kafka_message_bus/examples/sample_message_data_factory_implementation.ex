defmodule KafkaMessageBus.Examples.SampleMessageDataFactoryImplementation do
  @moduledoc """
  A set of functions that takes resource, action, and data as parameters and returns an
  instance of the appropriate message data struct. Each message data type will support a
  function new/1 that is a struct representation of the map data that it received. These
  new/1 functions do not alter or validate the data field values.

  This is an example of a message data factory implementation. One of these must
  defined and wired into the validator through the config (see: test.config for
  an example).

  Factory implementations will have n number of on_create/3 functions that take
  three parameters. The first parameter is the message data (data field form the
  kafka message structure) in the form of a map. The second parameter is the
  Kafka resource(s), and the third is the Kafka action. The factory will use
  the resource and action to map to a message data type. Each on_create function
  will call the associated message data type's new/1 function at the end of
  on_create.

  At the end of each factory definition you should use UnrecognizedMessageDataType's
  on_create function. This is the default behavior for unrecognized message data
  types that are encountered on the bus.
  """
  alias KafkaMessageBus.Examples.SampleMessageData2
  alias KafkaMessageBus.Messages.MessageData.UnrecognizedMessageDataType
  require Logger

  def on_create(%{} = data, "sample_resource", "sample_action") do
    Logger.info(fn -> "Creating for sample_resource and sample_action: #{inspect(data)}" end)
    SampleMessageData2.new(data)
  end

  use UnrecognizedMessageDataType, :on_create
end
