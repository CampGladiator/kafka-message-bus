defmodule KafkaMessageBus.Messages.MessageData.Validator.DateTimeValidatorTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias KafkaMessageBus.Messages.MessageData.Validator.DateTimeValidator

  describe "is_valid_date_time_utc" do
    test "returns ok tuple if passes" do
      message_data = %{datetime: "2019-11-19T19:22:26.779098Z"}

      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_date_time_utc(message_data, :datetime, :required)

      {:ok, datetime1, _} = DateTime.from_iso8601("2019-11-19 19:22:26.779098Z")
      assert validated_message_data == %{datetime: datetime1}
    end

    test "'T' is optional in date string" do
      datetime_string = "2019-11-19 19:22:26.779098Z"
      message_data = %{datetime: datetime_string}

      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_date_time_utc(message_data, :datetime, :required)

      {:ok, datetime1, _} = DateTime.from_iso8601("2019-11-19 19:22:26.779098Z")
      assert validated_message_data == %{datetime: datetime1}
    end

    test "invalid date format" do
      fun = fn ->
        {:error, error_data} =
          DateTimeValidator.is_valid_date_time_utc(
            %{datetime: "2015-01-23:23:50:07"},
            :datetime,
            :not_required
          )

        {err_msg, field_name, field_value} = error_data
        assert err_msg == :invalid_datetime
        assert field_name == :datetime
        assert field_value == "2015-01-23:23:50:07"
      end

      assert capture_log(fun) =~
               "[debug] Error encountered while parsing from_iso8601: :invalid_format"
    end

    test "returns error if nil provided when required" do
      {:error, error_data} =
        DateTimeValidator.is_valid_date_time_utc(%{datetime: nil}, :datetime, :required)

      {err_msg, field_name, field_value} = error_data
      assert err_msg == :field_required
      assert field_name == :datetime
      refute field_value
    end

    test "allows nil when not required" do
      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_date_time_utc(%{datetime: nil}, :datetime, :not_required)

      assert validated_message_data == %{}
    end
  end

  describe "is_valid_date_utc" do
    test "returns ok tuple if passes" do
      message_data = %{datetime: "2019-11-19"}

      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_date_utc(message_data, :datetime, :not_required)

      assert validated_message_data == %{datetime: ~D[2019-11-19]}
    end

    test "invalid date format" do
      fun = fn ->
        {:error, error_data} =
          DateTimeValidator.is_valid_date_utc(
            %{datetime: "2015-01-23:23:50:07"},
            :datetime,
            :not_required
          )

        {err_msg, field_name, field_value} = error_data
        assert err_msg == :invalid_date
        assert field_name == :datetime
        assert field_value == "2015-01-23:23:50:07"
      end

      assert capture_log(fun) =~
               "[debug] Error encountered while parsing from_iso8601: :invalid_format"
    end

    test "returns error if nil provided when required" do
      {:error, error_data} =
        DateTimeValidator.is_valid_date_utc(%{datetime: nil}, :datetime, :required)

      {err_msg, field_name, field_value} = error_data
      assert err_msg == :field_required
      assert field_name == :datetime
      refute field_value
    end

    test "allows nil by default" do
      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_date_utc(%{datetime: nil}, :datetime, :not_required)

      assert validated_message_data == %{}
    end

    test "passing anything other than a map for message data results in error" do
      assert DateTimeValidator.is_valid_date_utc("not-a-map", :datetime, :not_required) ==
               {:error, :message_data_must_be_a_map}
    end
  end

  describe "is_valid_time_utc" do
    test "returns ok tuple if passes" do
      datetime_string = "23:50:07"
      message_data = %{thetime: datetime_string}

      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_time_utc(message_data, :thetime, :not_required)

      assert validated_message_data == %{thetime: ~T[23:50:07]}
    end

    test "invalid date format" do
      fun = fn ->
        {:error, error_data} =
          DateTimeValidator.is_valid_time_utc(%{thetime: "23:23:50:07"}, :thetime, :not_required)

        {err_msg, field_name, field_value} = error_data
        assert err_msg == :invalid_time
        assert field_name == :thetime
        assert field_value == "23:23:50:07"
      end

      assert capture_log(fun) =~
               "[debug] Error encountered while parsing from_iso8601: :invalid_format"
    end

    test "returns error if nil provided when required" do
      {:error, error_data} =
        DateTimeValidator.is_valid_time_utc(%{thetime: nil}, :thetime, :required)

      {err_msg, field_name, field_value} = error_data
      assert err_msg == :field_required
      assert field_name == :thetime
      refute field_value
    end

    test "allows nil by default" do
      {:ok, validated_message_data} =
        DateTimeValidator.is_valid_time_utc(%{thetime: nil}, :thetime, :not_required)

      assert validated_message_data == %{}
    end
  end

  describe "from_iso8601" do
    test "errors that get passed to message_data pass through" do
      assert DateTimeValidator.from_iso8601("ignored", {:error, :the_error}) ==
               {:error, :the_error}
    end
  end
end
