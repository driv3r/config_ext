defmodule ConfigExtTest do
  use ExUnit.Case, async: false

  def no_args, do: "foo"
  def some_args(a, b), do: "bar-#{inspect(a)}-#{inspect(b)}"

  @env "ELIXIR_CONFIG_EXT_TEST_ENV"

  describe "ConfigExt.load/1" do
    test "input: without pattern; passes input through" do
      assert ConfigExt.load("foo") === {:ok, "foo"}
    end

    test "input: nil; passes input through" do
      assert ConfigExt.load(nil) === {:ok, nil}
    end

    test "input: {:system, nil}; returns error" do
      assert ConfigExt.load({:system, nil}) === {:error, "ENV Key: nil, is not a string"}
    end

    test "input: {:system, :key}; returns error" do
      assert ConfigExt.load({:system, :key}) === {:error, "ENV Key: :key, is not a string"}
    end

    test "input: {:system, key}; fetches key from system" do
      with_env "foo-var", fn ->
        assert ConfigExt.load({:system, @env}) === {:ok, "foo-var"}
      end
    end

    test "input: {:system, key}; when value is empty" do
      with_env "", fn ->
        assert ConfigExt.load({:system, @env}) === {:error, "ENV Key: ELIXIR_CONFIG_EXT_TEST_ENV is missing"}
      end
    end

    test "input: {:system, key}; when there's no env set" do
      assert ConfigExt.load({:system, @env}) === {:error, "ENV Key: ELIXIR_CONFIG_EXT_TEST_ENV is missing"}
    end

    test "input: {:system, key, default}; fetches key from system" do
      with_env "foo-var", fn ->
        assert ConfigExt.load({:system, @env, "bar"}) === {:ok, "foo-var"}
      end
    end

    test "input: {:system, key, default}; when value is empty, returns default" do
      with_env "", fn ->
        assert ConfigExt.load({:system, @env, "bar"}) === {:ok, "bar"}
      end
    end

    test "input: {:system, key, default}; when there's no env set, returns default" do
      assert ConfigExt.load({:system, @env, "bar"}) === {:ok, "bar"}
    end

    test "input: {:function, module, function, args}; when no args" do
      assert ConfigExt.load({:function, ConfigExtTest, :no_args, []}) === {:ok, "foo"}
    end

    test "input: {:function, module, function, args}; when args" do
      assert ConfigExt.load({:function, ConfigExtTest, :some_args, ["a", :b]}) === {:ok, "bar-\"a\"-:b"}
    end

    test "input: {:function, module, function, args}; when not a atom and list" do
      msg = {:error, "function needs to be an atom, and args a list of arguments"}
      assert ConfigExt.load({:function, ConfigExtTest, "no_args", []}) === msg
      assert ConfigExt.load({:function, ConfigExtTest, :no_args, nil}) === msg
      assert ConfigExt.load({:function, ConfigExtTest, :some_args, %{foo: :bar}}) === msg
    end

    test "input: {:function, module, function, args}; when module/function doesn't exist" do
      assert ConfigExt.load({:function, ConfigExtTest, :no_args, [:a, :b]}) === {:error, "function ConfigExtTest.no_args/2 is undefined or private. Did you mean one of:\n\n      * no_args/0\n"}
    end
  end

  describe "ConfigExt.load/2" do
    test "input: without pattern; passes input through" do
      assert ConfigExt.load("foo") === {:ok, "foo"}
    end

    test "input: nil; returns default" do
      assert ConfigExt.load(nil, "bar") === {:ok, "bar"}
    end

    test "input: {:system, nil}; returns default" do
      assert ConfigExt.load({:system, nil, "bar"}) === {:ok, "bar"}
    end

    test "input: {:system, :key}; returns default" do
      assert ConfigExt.load({:system, :key, "bar"}) === {:ok, "bar"}
    end

    test "input: {:system, key}; fetches key from system" do
      with_env "foo-var", fn ->
        assert ConfigExt.load({:system, @env}, "bar") === {:ok, "foo-var"}
      end
    end

    test "input: {:system, key}; when value is empty" do
      with_env "", fn ->
        assert ConfigExt.load({:system, @env}, "bar") === {:ok, "bar"}
      end
    end

    test "input: {:system, key}; when there's no env set" do
      assert ConfigExt.load({:system, @env}, "bar") === {:ok, "bar"}
    end

    test "input: {:system, key, default}; fetches key from system" do
      with_env "foo-var", fn ->
        assert ConfigExt.load({:system, @env, "baz"}, "bar") === {:ok, "foo-var"}
      end
    end

    test "input: {:system, key, default}; when value is empty, returns default" do
      with_env "", fn ->
        assert ConfigExt.load({:system, @env, "baz"}, "bar") === {:ok, "baz"}
      end
    end

    test "input: {:system, key, default}; when there's no env set, returns default" do
      assert ConfigExt.load({:system, @env, "baz"}, "bar") === {:ok, "baz"}
    end

    test "input: {:function, module, function, args}; when no args" do
      assert ConfigExt.load({:function, ConfigExtTest, :no_args, []}, "bar") === {:ok, "foo"}
    end

    test "input: {:function, module, function, args}; when args" do
      assert ConfigExt.load({:function, ConfigExtTest, :some_args, ["a", :b]}, "bar") === {:ok, "bar-\"a\"-:b"}
    end

    test "input: {:function, module, function, args}; when not a atom and list" do
      assert ConfigExt.load({:function, ConfigExtTest, "no_args", []}, "bar") === {:ok, "bar"}
      assert ConfigExt.load({:function, ConfigExtTest, :no_args, nil}, "bar") === {:ok, "bar"}
      assert ConfigExt.load({:function, ConfigExtTest, :some_args, %{foo: :bar}}, "bar") === {:ok, "bar"}
    end

    test "input: {:function, module, function, args}; when module/function doesn't exist" do
      assert ConfigExt.load({:function, ConfigExtTest, :no_args, [:a, :b]}, "bar") === {:ok, "bar"}
    end
  end

  describe "ConfigExt.load!/1" do
    test "input: {:system, key}, returns value" do
      with_env "foo-var", fn ->
        assert ConfigExt.load!({:system, @env}) === "foo-var"
      end
    end

    test "input: nil, returns nil" do
      assert ConfigExt.load!(nil) === nil
    end

    test "input: that would give error" do
      assert_raise ArgumentError, fn -> ConfigExt.load!({:system, nil}) end
    end
  end

  describe "ConfigExt.load!/2" do
    test "input: {:system, key}, returns value" do
      with_env "foo-var", fn ->
        assert ConfigExt.load!({:system, @env}, "bar") === "foo-var"
      end
    end

    test "input: nil, returns nil" do
      assert ConfigExt.load!(nil, "bar") === "bar"
    end

    test "input: that would give error" do
      assert ConfigExt.load!({:system, nil}, "bar") === "bar"
    end
  end

  describe "ConfigExt.get_env/3" do
    test "config: nil, default: nil, returns nil" do
      assert ConfigExt.get_env(:config_ext, @env) === nil
    end

    test "config: nil, default: 'bar', returns 'bar'" do
      assert ConfigExt.get_env(:config_ext, @env, "bar") === "bar"
    end

    test "config: 'foo', default: 'bar', returns 'foo'" do
      with_app "foo", fn ->
        assert ConfigExt.get_env(:config_ext, @env, "bar") === "foo"
      end
    end

    test "config: {:system, #{@env}}, #{@env}=baz default: 'bar', returns #{@env}" do
      with_env "baz", fn ->
        with_app {:system, @env}, fn ->
          assert ConfigExt.get_env(:config_ext, @env, "bar") === "baz"
        end
      end
    end

    test "config: {:function, ConfigExtTest, :some_args, [:a, :b]}, default: 'bar', returns 'bar-:a-:b'" do
      with_app {:function, ConfigExtTest, :some_args, [:a, :b]}, fn ->
        assert ConfigExt.get_env(:config_ext, @env, "bar") === "bar-:a-:b"
      end
    end

    test "config: {:system, #{@env}}, #{@env}=nil, default: 'bar', returns 'bar'" do
      with_app {:system, @env}, fn ->
        assert ConfigExt.get_env(:config_ext, @env, "bar") === "bar"
      end
    end
  end

  describe "ConfigExt.fetch_env/2" do
    test "config: nil, returns :error" do
      assert ConfigExt.fetch_env(:config_ext, @env) === :error
    end

    test "config: 'foo', returns {:ok, 'foo'}" do
      with_app "foo", fn ->
        assert ConfigExt.fetch_env(:config_ext, @env) === {:ok, "foo"}
      end
    end

    test "config: {:system, #{@env}}, #{@env}=baz, returns {:ok, 'baz'}" do
      with_env "baz", fn ->
        with_app {:system, @env}, fn ->
          assert ConfigExt.fetch_env(:config_ext, @env) === {:ok, "baz"}
        end
      end
    end

    test "config: {:function, ConfigExtTest, :some_args, [:a, :b]}, returns {:ok, 'bar-:a-:b'}" do
      with_app {:function, ConfigExtTest, :some_args, [:a, :b]}, fn ->
        assert ConfigExt.fetch_env(:config_ext, @env) === {:ok, "bar-:a-:b"}
      end
    end

    test "config: {:system, #{@env}}, #{@env}=nil, returns :error" do
      with_app {:system, @env}, fn ->
        assert ConfigExt.fetch_env(:config_ext, @env) === :error
      end
    end
  end

  describe "ConfigExt.fetch_env!/2" do
    test "config: nil, raises exception" do
      assert_raise ArgumentError, fn ->
        ConfigExt.fetch_env!(:config_ext, @env)
      end
    end

    test "config: 'foo', returns 'foo'" do
      with_app "foo", fn ->
        assert ConfigExt.fetch_env!(:config_ext, @env) === "foo"
      end
    end

    test "config: {:system, #{@env}}, #{@env}=baz, returns 'baz'" do
      with_env "baz", fn ->
        with_app {:system, @env}, fn ->
          assert ConfigExt.fetch_env!(:config_ext, @env) === "baz"
        end
      end
    end

    test "config: {:function, ConfigExtTest, :some_args, [:a, :b]}, returns 'bar-:a-:b'" do
      with_app {:function, ConfigExtTest, :some_args, [:a, :b]}, fn ->
        assert ConfigExt.fetch_env!(:config_ext, @env) === "bar-:a-:b"
      end
    end

    test "config: {:system, #{@env}}, #{@env}=nil, raises ArgumentError" do
      assert_raise ArgumentError, fn ->
        with_app {:system, @env}, fn ->
          ConfigExt.fetch_env!(:config_ext, @env)
        end
      end
    end
  end

  defp with_env(val, funk) do
    System.put_env @env, val
    funk.()
  after
    System.delete_env @env
  end

  defp with_app(val, funk) do
    Application.put_env :config_ext, @env, val
    funk.()
  after
    Application.delete_env :config_ext, @env
  end
end
