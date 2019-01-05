defmodule Servy.FourOhFourCounter do
  alias Servy.GenericServer
  @name :four_oh_four_conter

  def start() do
    IO.puts("Starting the Four Oh Four Counter...")
    GenericServer.start(__MODULE__, [], @name)
  end

  def bump_count(path) do
    GenericServer.call(@name, {:bump_count, path})
  end

  def get_count(path) do
    GenericServer.call(@name, {:get_count, path})
  end

  def get_counts() do
    GenericServer.call(@name, :get_counts)
  end

  def reset do
    GenericServer.cast(@name, :reset)
  end

  def handle_call({:bump_count, path}, state) do
    new_state = [path | state]
    {path, new_state}
  end

  def handle_call({:get_count, path}, state) do
    total = Enum.count(state, fn x -> x == path end)
    {total, state}
  end

  def handle_call(:get_counts, state) do
    counters =
      Enum.uniq(state)
      |> Enum.map(fn x -> {x, Enum.count(state, fn y -> y == x end)} end)
      |> Map.new()

    {counters, state}
  end

  def handle_cast(:reset, _state) do
    %{}
  end
end
