defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_args) do
    IO.puts("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    initial_time = :timer.minutes(60)

    children = [
      Servy.PledgeServer,
      %{
        id: Servy.SensorServer,
        start: {Servy.SensorServer, :start_link, [initial_time]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
