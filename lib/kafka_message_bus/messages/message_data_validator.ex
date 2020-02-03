defmodule KafkaMessageBus.MessageDataValidator do
  @moduledoc """
  Module includes a set of validate functions. These functions take wither the message
  data in isolation or in the context of the message itself and it returns the validation
  result.

  Validation results will either return one of the following:
  1. The tuple {:ok, :message_contract_excluded}
  1.1. This indicates that the specified message is excluded from validation.
  2. {:ok, %{}} (empty map)
  2.1. This indicates the message is valid with no suggested changes.
  3. {:ok, map}
  3.1. This indicates that the data is valid but was provided as the wrong type. For
        example, the message contract could be expected an integer but encounters a
        string that could be parsed into an integer. The map returned in the :ok tuple
        is a map of suggested changes with the data in the proper type for the
        specified field. Using the example above, if the data included something like
        %{the_field: "42"}, the resulting map would include %{the_field: 42}.
  4. An error tuple.
  """
  alias KafkaMessageBus.Messages.MessageData
  alias KafkaMessageBus.Messages.MessageData.Factory

  def validate({:error, _} = error), do: error
  def validate({:ok, :message_contract_excluded} = excluded), do: excluded
  def validate({:ok, message_data}), do: MessageData.validate(message_data)

  def validate(%{"data" => message_data, "action" => action, "resource" => resource}),
    do: validate(message_data, resource, action)

  def validate(%{} = message), do: {:error, "Could not process message: #{inspect(message)}"}

  def validate(message_data, resource, action) do
      message_data
      |> Factory.create(resource, action)
      |> validate
    end
end
