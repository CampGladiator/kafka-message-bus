defmodule KafkaMessageBus.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kafka_message_bus,
      version: "4.3.2",
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
        "Calvin Gerling",
        "Eliseu Daroit",
        "Fernando Heck",
        "Gabriel Alves",
        "Joshua Lockwood",
        "Kyle Preston",
        "Megan Weijiang",
        "Thales Yokoyama"
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
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.20.0"},
      {:exq, "~> 0.14"},
      {:jason, "~> 1.2"},
      {:kaffe, "~> 1.11"},
      {:brod, "3.4.0"},
      {:phoenix_ecto, "~> 4.0"}
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
