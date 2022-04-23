defmodule CoinGecko.Flow.StateTest do
  use ExUnit.Case, async: true

  alias CoinGecko.Flow.Supervisor
  alias CoinGecko.Flow.State

  setup do
    Supervisor.start_child(CoinGecko.Flow.State, %{
      id: "123456",
      current_state: "GET_STARTED_PAYLOAD"
    })

    {:ok, id: "123456", current_state: "GET_STARTED_PAYLOAD"}
  end

  describe "State" do
    test "get_state/1", %{id: id, current_state: current_state} do
      assert %{current_state: ^current_state} = State.get_state(id)
    end

    test "update_state/2", %{id: id} do
      updated_state = "UPDATED_STATE"
      State.update_state(id, %{current_state: updated_state})

      assert %{current_state: ^updated_state} = State.get_state(id)
    end
  end
end
