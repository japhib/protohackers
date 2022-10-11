defmodule P0SmokeTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :p0_smoke_test,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      # mod: {P0SmokeTest, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    []
  end
end
