defmodule Servy.PledgeServer do
  # alias HTTPoison
  alias Servy.GenericServer
  @name :pledge_server

  # CLIENTE INTERFACE FUNCTIONS
  def start() do
    IO.puts("Starting the pledge server...")
    GenericServer.start(__MODULE__, [], @name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenericServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@name, :clear)
  end

  def send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    # url = "https://putsreq.com/gSjF80g1XBYIxaUak32L"
    # body = ~s({"name": #{name}, "amount": #{amount}})
    # headers = [{"Content-Type", "application/json"}]

    # HTTPoison.post(url, body, headers)

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  # SERVER CALLBACKS
  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
    {total, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end
end

# alias Servy.PledgeServer

# pid = spawn(PledgeServer, :listen_loop, [[]])

# send pid, {:create_pledge, "larry", 10}
# send pid, {:create_pledge, "moe", 20}
# send pid, {:create_pledge, "curly", 30}
# send pid, {:create_pledge, "daisy", 40}
# send pid, {:create_pledge, "grace", 50}

# send pid, {self(), :recent_pledges}

# receive do {:response, pledges} -> IO.inspect pledges end

# pid = PledgeServer.start()

# send pid, {:stop, "hammertime"}

# IO.inspect PledgeServer.create_pledge("larry", 10)
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
# IO.inspect PledgeServer.create_pledge("daisy", 40)
# IO.inspect PledgeServer.create_pledge("grace", 50)

# IO.inspect PledgeServer.recent_pledges()

# IO.inspect PledgeServer.total_pledged()
