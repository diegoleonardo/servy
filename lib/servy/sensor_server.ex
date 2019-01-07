defmodule Servy.SensorServer do
  @name :sensor_server

  use GenServer
  alias Servy.StateSensor

  # Client Interface

  def start_link(interval) do
    IO.puts("Starting the Sensor Server...")
    IO.puts("Starting the sensor server with #{interval} seconds refresh...")
    initial_state = %StateSensor{refresh_interval: interval}
    GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def get_sensor_data do
    GenServer.call(@name, :get_sensor_data)
  end

  def set_refresh_interval(time) do
    GenServer.cast(@name, {:set_refresh_interval, time})
  end

  # Server Callbacks

  def init(state) do
    initial_sensor = run_tasks_to_get_sensor_data()
    initial_state = %{state | sensor: initial_sensor}
    schedule_refresh(state)
    {:ok, initial_state}
  end

  def handle_info(:refresh, state) do
    IO.puts("Refreshing the cache...")
    refresh_sensors = run_tasks_to_get_sensor_data()
    new_state = %{state | sensor: refresh_sensors}
    schedule_refresh(state)
    {:noreply, new_state}
  end

  defp schedule_refresh(state) do
    Process.send_after(self(), :refresh, state.refresh_interval)
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor, state}
  end

  def handle_cast({:set_refresh_interval, time}, state) do
    new_state = %{state | refresh_interval: time}
    schedule_refresh(new_state)
    {:noreply, new_state}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data...")

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end

  def child_spec(:frequent) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [1]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def child_spec(:infrequent) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [60]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end
end
