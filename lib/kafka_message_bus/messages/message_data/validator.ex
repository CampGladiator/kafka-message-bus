defmodule KafkaMessageBus.Messages.MessageData.Validator do
  @moduledoc """
  The MessageData Validator module contains functions used to support Ecto
  schema validation.
  """
  import Ecto.Changeset

  def validate_required_inclusion(changeset, fields,  _options \\ []) do
    if Enum.any?(fields, fn(field) -> get_field(changeset, field) end),
       do: changeset,
       else: add_error(changeset, hd(fields), "One of these fields must be present: #{inspect fields}")
  end
end
