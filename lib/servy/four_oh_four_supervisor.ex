defmodule Servy.FourOhFourSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [Servy.FourOhFourCounter]
    opts = [strategy: :one_for_one, max_restarts: 5, max_seconds: 10]
    Supervisor.init(children, opts)
  end
end
