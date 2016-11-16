defmodule Pay.Mixfile do
  use Mix.Project

  def project do
    [app: :pay,
     version: "0.1.2",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :maru, :httpoison, :tzdata]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:maru, "~> 0.7"},
    {:httpoison, "~> 0.8"},
    {:timex, "~> 3.0"},
    {:mock, "~> 0.1.1", only: :test},
    {:dogma, "~> 0.0", only: :dev}]
  end
end
