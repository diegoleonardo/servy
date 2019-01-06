defmodule Servy.FourOhFourCounter do
  use GenServer
  @name :four_oh_four_conter

  def start() do
    IO.puts("Starting the Four Oh Four Counter...")
    GenServer.start(__MODULE__, [], name: @name)
  end

  def bump_count(path) do
    GenServer.call(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@name, {:get_count, path})
  end

  def get_counts() do
    GenServer.call(@name, :get_counts)
  end

  def reset do
    GenServer.cast(@name, :reset)
  end

  def handle_call({:bump_count, path}, _from, state) do
    new_state = [path | state]
    {:reply, path, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    total = Enum.count(state, fn x -> x == path end)
    {:reply, total, state}
  end

  def handle_call(:get_counts, _from, state) do
    counters =
      Enum.uniq(state)
      |> Enum.map(fn x -> {x, Enum.count(state, fn y -> y == x end)} end)
      |> Map.new()

    {:reply, counters, state}
  end

  def handle_cast(:reset, _state) do
    new_state = []
    {:noreply, new_state}
  end
end
