defmodule KafkaMessageBus.Adapters.Kaffe.Consumer do
  alias KafkaMessageBus.{ConsumerHandler, Utils}

  require Logger

  def handle_message(message) do
    Logger.info(fn ->
      "Received Kaffe message"
    end)

    message.value
    |> Jason.decode()
    |> configure_logger()
    |> run_consumers(message.topic)

    Utils.clear_log_metadata()

    :ok
  end

  defp configure_logger({:ok, message} = result) do
    Utils.set_log_metadata(message)

    result
  end

  defp configure_logger({:error, _reason} = message) do
    message
  end

  defp run_consumers({:ok, contents}, topic) do
    case get_consumers_for(topic, contents["resource"]) do
      [] ->
        Logger.info(fn ->
          "No consumers configured for #{topic}/#{contents["resource"]}"
        end)

      consumers ->
        Enum.each(consumers, fn consumer -> run_consumer(consumer, contents) end)
    end
  end

  defp run_consumers({:error, message}, topic) do
    Logger.error(fn ->
      "Failed to decode Kaffe message on topic #{topic}: #{inspect(message)}"
    end)
  end

  defp run_consumer(consumer, message) do
    case ConsumerHandler.perform(consumer, message) do
      :ok ->
        Logger.info(fn ->
          "Message successfully processed by #{consumer}"
        end)

        :ok

      {:error, reason} ->
        Logger.error(fn ->
          "Failed to run handler - will produce `dead_letter_queue` message. Reason: #{
            inspect(reason)
          }"
        end)

        message = %{"message" => message, "consumer" => consumer, "previous_error" => reason}

        KafkaMessageBus.produce(message, nil, "failure", "retry", topic: "dead_letter_queue")
    end
  end

  defp get_consumers_for(topic, resource) do
    :kaffe
    |> Application.get_env(:app_consumers)
    |> Enum.flat_map(fn
      {^topic, ^resource, module} -> [module]
      _ -> []
    end)
  end
end
