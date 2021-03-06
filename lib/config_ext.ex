defmodule ConfigExt do
  @moduledoc """
  A helper module, which contains common functions used around loading config at runtime.
  """

  @doc """
  Returns the **evaluated** value for `key` in `app`'s environment as a tuple.

  If the configuration parameter does not exist, or pattern fails the function returns :error.

  A drop in replacement for `Application.fetch_env/2`.
  """
  def fetch_env(app, key) do
    case Application.fetch_env(app, key) do
      {:ok, val} ->
        case load(val) do
          {:ok, value} -> {:ok, value}
          {:error, _}  -> :error
        end
      :error -> :error
    end
  end

  @doc """
  Returns the **evaluated** value for `key` in `app`'s environment.

  If the configuration parameter does not exist or pattern will fail, raises ArgumentError.

  A drop in replacement for `Application.fetch_env!/2`.
  """
  def fetch_env!(app, key) do
    Application.fetch_env!(app, key) |> load!
  end

  @doc """
  Returns the **evaluated** value for `key` in `app`'s environment.

  If the configuration parameter does not exist or pattern will fail, the function returns the default value.

  A drop in replacement for `Application.get_env/3`.
  """
  def get_env(app, key, default \\ nil) do
    Application.get_env(app, key, default) |> load!(default)
  end

  @doc """
  Same as `ConfigExt.load/1` but instead of tuple, returns the value directly and on `:error` raises `ArgumentError`.

  ## Examples

  Given `CONFIG_EXT_TEST=foo` is set in environment.

      iex> ConfigExt.load!({:system, "CONFIG_EXT_TEST"})
      "foo"

  When `CONFIG_EXT_TEST` is not set.

      iex> ConfigExt.load!({:system, "CONFIG_EXT_TEST"})
      ** (ArgumentError) ENV Key: CONFIG_EXT_TEST is missing
          (config_ext) lib/config_ext.ex:24: ConfigExt.load!/1
  """
  def load!(value) do
    case load(value) do
      {:ok, val} -> val
      {:error, msg} -> raise ArgumentError, msg
    end
  end

  @doc """
  Same as `ConfigExt.load!/1` but will return default value instead of raising exception.

  ## Examples

  Given `CONFIG_EXT_TEST=foo` is set in environment.

      iex> ConfigExt.load!({:system, "CONFIG_EXT_TEST"}, "bar")
      "foo"

  When `CONFIG_EXT_TEST` is not set.

      iex> ConfigExt.load!({:system, "CONFIG_EXT_TEST"}, "bar")
      "bar"
  """
  def load!(value, default) do
    case load(value, default) do
      {:ok, value} -> value
      {:error, _}  -> default
    end
  end

  @doc """
  Looks for dynamic patterns in input, when found - evals them - otherwise passes input forward. Supported input formats are:

      {:system, KEY}
      {:system, KEY, default}
      {:function, Module, function_name} # which expands to below version with empty list of arguments
      {:function, Module, function_name, [arg1, ...]}

  Returns a tuple with two elements:

  - `{:ok, value}` for matched pattern if the environment variable is present, or default is present, or if the pattern wasn't found.
  - `{:error, message}` if given environment variable was empty and there was no default value.

  ## Examples

  Given `CONFIG_EXT_TEST=foo` is set in environment.

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST"})
      {:ok, "foo"}

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST", "bar"})
      {:ok, "foo"}

  When `CONFIG_EXT_TEST` is not set.

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST"})
      {:error, ""}

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST", "bar"})
      {:ok, "bar"}

  For input with function pattern.

      defmodule Foo do
        def bar, do: "baz"
      end

      iex> ConfigExt.load({:function, Foo, :bar, []})
      {:ok, "baz"}

  Function pattern should return a non `nil` value, otherwise it's an error.

      defmodule Foo do
        def bar, do: nil
      end

      iex> ConfigExt.load({:function, Foo, :bar, []})
      {:error, "empty value"}

  If the function doesn't exist or it's private you should get correct error message as well.

  For input without pattern.

      iex> ConfigExt.load(:error)
      {:ok, :error} # for example logger level

      iex> ConfigExt.load("baz")
      {:ok, "baz"}
  """
  def load({:system, key}) when is_bitstring(key) do
    case System.get_env(key) do
      nil -> error(key)
      ""  -> error(key)
      val -> {:ok, val}
    end
  end

  def load({:system, key}), do: {:error, "ENV Key: #{inspect(key)}, is not a string"}
  def load({:system, key, default}), do: load({:system, key}, default)

  def load({:function, module, function}) do
    load({:function, module, function, []})
  end

  def load({:function, module, function, args})
  when is_atom(function) and is_list(args) do
    case Kernel.apply(module, function, args) do
      nil -> {:error, "empty value"}
      val -> {:ok, val}
    end
  rescue
    e in UndefinedFunctionError -> {:error, Exception.message(e)}
  end

  def load({:function, _mod, _fun, _args}), do: {:error, "function needs to be an atom, and args a list of arguments"}
  def load(value), do: {:ok, value}

  defp error(key), do: {:error, "ENV Key: #{key} is missing"}

  @doc """
  An extension to `ConfigExt.load/1` function, which accepts default value as a second argument.

  Returns:

  - `{:ok, value}` as in `ConfigExt.load/1`
  - `{:ok, default}` in case of:
    - pattern failure
    - `nil` input value

  ## Examples

  Given `CONFIG_EXT_TEST=foo` is set in environment.

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST"}, "baz")
      {:ok, "foo"}

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST", "bar"}, "baz")
      {:ok, "foo"}

  When `CONFIG_EXT_TEST` is not set, default value is used.

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST"}, "baz")
      {:ok, "baz"}

  When pattern comes with default, it takes precedence before the given one.

      iex> ConfigExt.load({:system, "CONFIG_EXT_TEST", "bar"}, "baz")
      {:ok, "bar"}

  For input with function pattern.

      defmodule Foo do
        def bar, do: "baz"
      end

      iex> ConfigExt.load({:function, Foo, :bar, []}, "buz")
      {:ok, "baz"}

  Function pattern should return a non `nil` value, otherwise default value will get returned.

      defmodule Foo do
        def bar, do: nil
      end

      iex> ConfigExt.load({:function, Foo, :bar, []}, "buz")
      {:ok, "buz"}

  If the function doesn't exist or it's private you should get a `{:ok, default}` as well.

  For input without pattern.

      iex> ConfigExt.load(:error, "baz")
      {:ok, :error} # as :error is a valid input

      iex> ConfigExt.load("foo", "bar")
      {:ok, "foo"}
  """
  def load({:system, key}, default) do
    case load({:system, key}) do
      {:error, _} -> {:ok, default}
      {:ok, val}  -> {:ok, val}
    end
  end

  def load({:system, key, user_default}, _default) do
    load({:system, key}, user_default)
  end

  def load({:function, module, function}, default) do
    load({:function, module, function, []}, default)
  end

  def load({:function, module, function, args}, default) do
    case load({:function, module, function, args}) do
      {:error, _msg} -> {:ok, default}
      {:ok, val}     -> {:ok, val}
    end
  end

  def load(nil, default), do: {:ok, default}
  def load(value, _default), do: {:ok, value}
end
