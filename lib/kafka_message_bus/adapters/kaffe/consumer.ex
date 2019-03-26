defmodule KafkaMessageBus.Adapters.Kaffe.Consumer do
  alias KafkaMessageBus.ConsumerHandler

  require Logger

  def handle_message(message) do
    Logger.debug(fn ->
      "Kaffe message received"
    end)

    message.value
    |> Poison.decode()
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
          KafkaMessageBus.produce("dead_letter_queue", nil, nil, nil)
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
