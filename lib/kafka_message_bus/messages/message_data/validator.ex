defmodule KafkaMessageBus.Messages.MessageData.Validator do
  @moduledoc """
  The MessageData Validator module contains functions used for validating MessageData
  protocol implementors.
  """
  import KafkaMessageBus.Messages.MessageData.Validator.Response
  import Ecto.Changeset

  require Logger
  alias KafkaMessageBus.Messages.MessageData.MapUtil

  @topics ~w(camp campaign log notification organization sign_contracts user)
  @resources ~w(area card division enrollment location note organization
  product_order push_token region shirt_order trainer_training_session
  training_session user)
  @actions ~w(nation_created nation_deleted nation_product_claimed
  nation_product_owned nation_set_default nation_shirt_claimed
  nation_shirt_owned nation_statistic nation_updated nation_user_can_checkin)
  @enrollment_status ["ACTIVE", "INACTIVE", "FROZEN", "SUSPENDED"]
  @enrollment_types ["BOLD6", "BOLD12", "BOLD24", "CAMP", "FUTURE_CAMPER", "OWF"]

  @doc "
  This function processes the execution of a list of validation functions.

  Each validation function must take one parameter for the message_data body.
  If all validations pass it will return an :ok tuple that contains a map with
  change suggestions, if any (it will return an empty map if there are no change
  suggestions). The fields in the change suggestion map correspond to fields
  in the message_data body. Once validation is complete the change suggestion
  map will be used to replace values with their type-safe equivalents.
  Example:
    No change suggestion: {:ok, %{}}
    Change suggestion: {:ok, %{field_name_to_update: new_field_value}}

  If any validation errors are encountered the validate/2 function will return an error
  tuple with a list of all failed validations.
  Example: {:error, [{:error_message1, :field_name, field_value}, {:error_message2, :field_name, field_value}]}

  In regard to individual validation functions:

  For simplicity, the ok() function is provided to prepare validator ok responses.
  Example:
    No change suggestion: ok()
    Change suggestion: ok(field_name, field_value)
    To return

  If validation passes for the validator function (with no change suggestions) it should
  return an :ok tuple that contains the validated message_data struct.
  Example: {:ok, %{}} OR ok()

  If validation fails for the validator function it should return an :error tuple that
  a tuple with the validation failure information.
  Example: {:error, {:error_message, :field_name, field_value}}
  "
  def validate(validation_functions, message_data) do
    validation_functions
    |> do_validate(message_data)
    |> apply_change_suggestions(message_data)
  end

  def do_validate(validation_functions, message_data) do
    if Enum.any?(validation_functions) do
      validation_functions
      |> execute_validations(message_data)
      |> prepare_validation_results
    else
      ok()
    end
  end

  def nested_validate(validation_functions, message_data, parent_name)
      when is_list(validation_functions) and is_atom(parent_name) do
    case do_nested_validation(validation_functions, message_data, parent_name) do
      {:ok, nested_data} when nested_data == %{} ->
        ok(%{})

      {:ok, nested_data} ->
        ok(Map.put(%{}, parent_name, nested_data))

      {:error, err_list} when is_list(err_list) ->
        new_err_list =
          Enum.map(err_list, fn {err_atom, field_name, field_value} ->
            {err_atom, {parent_name, field_name}, field_value}
          end)

        {:error, new_err_list}

      err ->
        err
    end
  end

  def validate_required_inclusion(changeset, fields,  options \\ []) do
    if Enum.any?(fields, fn(field) -> get_field(changeset, field) end),
       do: changeset,
       else: add_error(changeset, hd(fields), "One of these fields must be present: #{inspect fields}")
  end

  defp do_nested_validation(validation_functions, message_data, parent_name)
       when is_atom(parent_name) do
    case MapUtil.safe_get(message_data, parent_name) do
      nil ->
        ok()

      nested_data ->
        do_validate(validation_functions, nested_data)
    end
  end

  def apply_change_suggestions({:error, err}, _message_data), do: {:error, err}

  def apply_change_suggestions(validation_err_list, _message_data)
      when is_list(validation_err_list),
      do: validation_err_list

  def apply_change_suggestions({:ok, suggested_changes}, message_data),
    do: apply_change_suggestions(suggested_changes, message_data)

  def apply_change_suggestions(suggested_changes, message_data) when is_map(suggested_changes),
    do:
      suggested_changes
      |> Map.keys()
      |> apply_change_suggestions(suggested_changes, message_data)
      |> ok

  defp apply_change_suggestions([change_key | remainder], suggested_changes, message_data) do
    new_value = get_suggested_value(change_key, suggested_changes, message_data)

    apply_change_suggestions(
      remainder,
      suggested_changes,
      Map.put(message_data, change_key, new_value)
    )
  end

  defp apply_change_suggestions([], _suggested_changes, message_data), do: message_data

  defp get_suggested_value(change_key, suggested_changes, message_data) do
    case MapUtil.safe_get(suggested_changes, change_key) do
      %{__struct__: _} = value ->
        value

      value when is_map(value) ->
        nested_suggestions = MapUtil.safe_get(suggested_changes, change_key)
        nested_message_data = MapUtil.safe_get(message_data, change_key)

        nested_suggestions
        |> Map.keys()
        |> apply_change_suggestions(nested_suggestions, nested_message_data)

      value ->
        value
    end
  end

  def valid_action?(action) when action in @actions, do: true
  def valid_action?(_action), do: false

  def valid_topic?(topic) when topic in @topics, do: true
  def valid_topic?(_topic), do: false

  def valid_resource?(resource) when resource in @resources, do: true
  def valid_resource?(_resource), do: false

  def execute_validations(validation_funcs, message_data) do
    Enum.reduce(validation_funcs, nil, fn func, acc ->
      execute_validation(func, acc, message_data)
    end)
  end

  def execute_validation(_validation_function, {:error, _} = accumulator, _message_data),
    do: accumulator

  def execute_validation(validation_function, accumulator, message_data) do
    case validation_function.(message_data) do
      {:ok, change_suggestions} ->
        validation_ok(accumulator, change_suggestions)

      {:error, error_tuple = {_err_msg, _field_name, _field_value}} ->
        add_validation_error(accumulator, error_tuple)

      {:error, error_list} when is_list(error_list) ->
        add_validation_error(accumulator, error_list)

      err ->
        Logger.info(fn -> "Failure encountered while validating: #{inspect(err)}" end)
        err
    end
  end

  defp validation_ok(acc, _change_suggestions) when is_list(acc), do: acc
  defp validation_ok(nil, change_suggestions), do: ok(change_suggestions)

  defp validation_ok({:ok, acc_suggestions}, change_suggestions),
    do:
      acc_suggestions
      |> Map.merge(change_suggestions)
      |> ok

  defp add_validation_error({:ok, _}, err_list) when is_list(err_list),
    do: add_validation_error([], err_list)

  defp add_validation_error(nil, err_list) when is_list(err_list),
    do: add_validation_error([], err_list)

  defp add_validation_error(acc, err_list) when is_list(err_list), do: acc ++ err_list

  defp add_validation_error(acc, {_err_msg, _field_name, _field_value} = error_tuple)
       when is_list(error_tuple),
       do: add_validation_error(acc, error_tuple)

  defp add_validation_error(acc, {_err_msg, _field_name, _field_value} = error_tuple)
       when is_list(acc),
       do: acc ++ [error_tuple]

  defp add_validation_error(_acc, {_err_msg, _field_name, _field_value} = error_tuple),
    do: [error_tuple]

  defp prepare_validation_results(result) when is_list(result), do: {:error, result}
  defp prepare_validation_results({:ok, _} = result), do: result
  defp prepare_validation_results({:error, _} = result), do: result

#  def required(message_data, field_name_or_fields),
#    do: RequiredValidator.required(message_data, field_name_or_fields)
#
#  def required(message_data, field_name, ok_function),
#    do: RequiredValidator.required(message_data, field_name, ok_function)

  defp remove_change_suggestions({:error, _} = err), do: err
  defp remove_change_suggestions({:ok, _}), do: ok()

  def enrollment_status, do: @enrollment_status
  def enrollment_types, do: @enrollment_types
end
