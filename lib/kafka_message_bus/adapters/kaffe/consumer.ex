defmodule KafkaMessageBus.Adapters.Kaffe.Consumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def handle_message(message) do
    Logger.debug(fn ->
      "Kaffe message received"
    end)

    message.value
    |> Jason.decode()
    |> run_consumers(message.topic)
  end

  defp run_consumers({:ok, contents}, topic) do
    case get_consumers_for(topic, contents["resource"]) do
      [] ->
        Logger.error(fn ->
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
        :ok

      {:error, reason} ->
        Logger.error(fn ->
          "Failed to run handler - will produce `dead_letter_queue` message. Reason: #{
            inspect(reason)
          }"
        end)

        message = %{"message" => message, "consumer" => consumer}

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
