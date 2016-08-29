defmodule TrueStory.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :true_story,
     version: @version,
     elixir: "~> 1.3-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),
     name: "TrueStory",
     docs: [source_ref: "v#{@version}",
            source_url: "https://github.com/ericmj/true_story",
            main: "readme", extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  defp description do
    "Make your tests tell a story"
  end

  defp package do
    [maintainers: ["Eric Meadows-Jönsson", "Bruce Tate"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/ericmj/true_story"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev}]
  end
end
