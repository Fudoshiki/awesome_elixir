defmodule AwesomeElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :awesome_elixir,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AwesomeElixir.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:earmark, "~> 1.4.10"},
      {:faker, "~> 0.14"},
      {:floki, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:hackney, "~> 1.16.0"},
      {:httpoison, "~> 1.7"},
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5.4"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.13.0"},
      {:plug_cowboy, "~> 2.0"},
      {:tesla, "~> 1.3.3"},
      {:timex, "~> 3.6.2"}
    ]
  end
end
