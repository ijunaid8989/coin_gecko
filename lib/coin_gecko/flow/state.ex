defmodule CoinGecko.Flow.State do
  use GenServer

  require Logger

  def start_link(opts) do
    {id, opts} = Map.pop!(opts, :id)
    GenServer.start_link(__MODULE__, opts, name: process_name(id))
  end

  def init(state) do
    {:ok, state}
  end

  def update_state(id, state) do
    GenServer.cast(via_tuple(id), {:update_state, state})
  end

  def handle_cast({:update_state, state}, _old_state) do
    {:noreply, state}
  end

  def get_state(id) do
    GenServer.call(via_tuple(id), :get)
  end

  def handle_call(:get, _from, state),
    do: {:reply, state, state}

  defp process_name(id),
    do: {:via, Registry, {StateRegistry, "state_for_#{id}"}}

  defp via_tuple(id) do
    {:via, Registry, {StateRegistry, "state_for_#{id}"}}
  end
end
