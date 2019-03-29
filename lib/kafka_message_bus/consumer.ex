defmodule KafkaMessageBus.Consumer do
  alias KafkaMessageBus.ConsumerEnqueuer

  require Logger

  @processor_config Application.get_env(:kafka_message_bus, :consumers)
  @retry_strategy Application.get_env(:kafka_message_bus, :retry_strategy)

  def handle_messages(nil), do: :ok

  def handle_messages(messages) do
    for message <- messages do
      Logger.info(fn ->
        "Got message: #{message.topic}/#{message.partition} -> #{message.key}: #{message.value}"
      end)

      message.value
      |> Poison.decode()
      |> process_message(message.topic)
    end

    :ok
  end

  defp process_message({:ok, msg_content}, topic) do
    Logger.metadata(request_id: msg_content["request_id"])

    Enum.each(@processor_config, &execute_message(msg_content, topic, &1))
  end

  defp process_message({:error, error}, topic) do
    Logger.error("Failed to parse message in topic #{topic}. Error: #{inspect(error)}")
  end

  defp execute_message(
         msg_content = %{"resource" => resource},
         topic,
         {topic, resource, message_processor}
       ) do
    Logger.debug(fn -> "[ACCEPTED] #{message_processor} - #{topic}: #{inspect(msg_content)}" end)

    try do
      message_processor.process(msg_content)
    rescue
      _ ->
        enqueue_message_retry(msg_content, message_processor, @retry_strategy)
    end
  end

  defp execute_message(%{"resource" => resource}, topic, {_, _, message_processor}) do
    Logger.debug(fn ->
      "[IGNORED] #{message_processor} - #{topic}: #{inspect(resource)}"
    end)

    :ok
  end

  defp enqueue_message_retry(msg_content, message_processor, retry_strategy)
       when retry_strategy == :exq do
    ConsumerEnqueuer.enqueue(msg_content, message_processor)
  end

  defp enqueue_message_retry(_, _, _) do
    Logger.warn("Will not retry message")
  end
end
