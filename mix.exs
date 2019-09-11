defmodule KafkaMessageBus.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kafka_message_bus,
      version: "4.1.1",
      elixir: "~> 1.7",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      description: description(),
      package: package(),
      name: "KafkaMessageBus",
      source_url: "https://github.com/CampGladiator/kafka_message_bus"
    ]
  end

  defp description do
    """
    A general purpose messaging utility library supporting Exq and Kaffe
    """
  end

  defp package do
    [
      maintainers: [
        "Alan Ficagna",
        "Eduardo Cunha",
        "Fernando Heck",
        "Gabriel Alves",
        "Matthias Nunes",
        "Gabriel Machado"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/CampGladiator/kafka_message_bus"
      }
    ]
  end

  def application do
    [
      mod: {KafkaMessageBus.Application, []},
      included_applications: [
        :kaffe,
        :exq
      ]
    ]
  end

  defp deps do
    [
      {:kaffe, "~> 1.11"},
      {:exq, "~> 0.12.1"},
      {:poison, "~> 3.0"},
      {:ex_doc, "~> 0.20.0"},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      lint: [
        "credo suggest --ignore-checks moduledoc,aliasusage,maxlinelength,aliasorder --strict"
      ]
    ]
  end
end
