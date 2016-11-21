# ConfigExt [![Build Status](https://travis-ci.org/driv3r/config_ext.svg?branch=master)](https://travis-ci.org/driv3r/config_ext)

A bunch of common elixir config helpers to load config from environment variables or by executing a function. Part of the work was based on gist from [bitwalker](https://gist.github.com/bitwalker/a4f73b33aea43951fe19b242d06da7b9) and community practises (especially for using `{:system, "VAR"[, default]}` spec).

## Installation

The package can be installed as:

  1. Add `config_ext` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:config_ext, "~> 0.2.0"}]
    end
    ```

## Usage

You can use the module to load info from system environment variables like

```elixir
# where LEVEL=debug
iex>
ConfigExt.load({:system, "LEVEL")
{:ok, "debug"}
```

or add default value as well

```elixir
# when LEVEL is empty
iex> ConfigExt.load({:system, "LEVEL", "info"})
{:ok, "info"}

# or in different format
iex> ConfigExt.load({:system, "LEVEL"}, "info")
{:ok, "info"}
```

or execute a function instead

```elixir
defmodule Foo do
  def bar(a), do: "baz-#{inspect(a)}"
end

iex> ConfigExt.load({:function, Foo, :bar, [:a]})
{:ok, "baz-:a"}
```

Of course it's meant to be run as part of other libaries, in order to load config dynamically, at the moment you can do it like:

```elixir
# i.e. in config.exs
config :logger, level: {:system, "LEVEL", "info"}

# then LEVEL=warn
iex> Application.get_env(:logger, :level) |> ConfigExt.load("error")
{:ok, "warn"}
```

See more in docs `ConfigExt.load/1` and `ConfigExt.load/2`.
