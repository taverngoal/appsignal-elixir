defmodule Appsignal.Error.BackendTest do
  use ExUnit.Case, async: true
  import AppsignalTest.Utils
  import ExUnit.CaptureIO
  alias Appsignal.{Error.Backend, Span, WrappedNif, WrappedTracer}

  setup do
    WrappedNif.start_link()
    WrappedTracer.start_link()
    :ok
  end

  test "is added as a Logger backend" do
    assert {:error, :already_present} = Logger.add_backend(Backend)
  end

  describe "when an exception is raised" do
    setup do
      [pid: spawn(fn -> raise "Exception" end)]
    end

    test "creates a span", %{pid: pid} do
      until(fn ->
        assert {:ok, [{"", nil, ^pid}]} = WrappedTracer.get(:create_span)
      end)
    end
  end
end