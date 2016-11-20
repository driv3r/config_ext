# ConfigExt

A bunch of common elixir config helpers to load config from environment variables or by executing a function. Part of the work was based on gist from [bitwalker](https://gist.github.com/bitwalker/a4f73b33aea43951fe19b242d06da7b9) and community practises (especially for using `{:system, "VAR"[, default]}` spec).

## Installation

The package can be installed as:

  1. Add `config_ext` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:config_ext, "~> 0.1.0"}]
    end
    ```

  2. Use module to fetch config from env var

    ```elixir
    # where LEVEL=debug
    config :logger, :level, {:system, "LEVEL", "info"}
    ConfigExt.get_env(:logger, :level) # => "debug"
    ```

    or evaluate a function on runtime

    ```elixir
    config :logger, :level, {:function, YourModule, :function_name, [:arg1, :arg2]}
    ConfigExt.get_env(:logger, :level) # => YourModule.function_name(:arg1, :arg2)
    ```
