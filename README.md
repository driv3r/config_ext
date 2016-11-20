# ConfigExt

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
