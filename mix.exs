defmodule ConfigExt.Mixfile do
  use Mix.Project

  def project do
    [app: :config_ext,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),

     # Hex
     description: description(),
     package: package(),

     # Docs
     name: "ConfigExt",
     source_url: github(),
     homepage_url: github(),
     docs: [
       main: "ConfigExt",
       extras: ["README.md"]
     ]
   ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    A bunch of common elixir config helpers to load config from environment variables or by executing a function.
    """
  end

  defp package do
    [
      name: :config_ext,
      files: ["lib/config_ext.ex", "mix.exs", "README.md", "LICENSE.md", "CHANGELOG.md"],
      maintainers: ["Leszek Zalewski"],
      licenses: ["MIT"],
      links: %{"GitHub" => github()}
    ]
  end

  defp github, do: "https://github.com/driv3r/config_ext"
end
