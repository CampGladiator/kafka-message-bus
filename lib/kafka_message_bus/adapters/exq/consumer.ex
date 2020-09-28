defmodule KafkaMessageBus.Adapters.Exq.Consumer do
  alias KafkaMessageBus.{ConsumerHandler, Utils}

  require Logger

  def perform(module, message) do
    Logger.info(fn ->
      "Received Exq message"
    end)

    message = Jason.decode!(message)

    Utils.set_log_metadata(message)

    :ok = ConsumerHandler.perform(module, message)

    Utils.clear_log_metadata()
  rescue
    e ->
      Utils.clear_log_metadata()

      reraise e, __STACKTRACE__
  end
end
