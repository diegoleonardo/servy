defmodule Servy do
  use Application
  alias Servy.FourOhFourCounter, as: Counter
  alias Servy.PledgeServer

  def start(_type, _args) do
    Counter.start()
    PledgeServer.start()
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
