defmodule Servy.PledgeServer do
  use GenServer
  alias Servy.StatePledge

  # alias HTTPoison
  @name :pledge_server

  # CLIENTE INTERFACE FUNCTIONS
  @spec start() :: :ignore | {:error, any()} | {:ok, pid()}
  def start() do
    # StatePledge{} é o argumento passado para a função init
    GenServer.start(__MODULE__, %StatePledge{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged)
  end

  def get_cache_size do
    GenServer.call(@name, :get_cache_size)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast(@name, {:set_cache_size, size})
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    # url = "https://putsreq.com/gSjF80g1XBYIxaUak32L"
    # body = ~s({"name": #{name}, "amount": #{amount}})
    # headers = [{"Content-Type", "application/json"}]

    # HTTPoison.post(url, body, headers)

    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example return value:
    [{"wilma", 15}, {"fred", 25}]
  end

  # SERVER CALLBACKS
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  def handle_cast({:set_cache_size, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %{state | cache_size: size, pledges: resized_cache}
    {:noreply, new_state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call(:get_cache_size, _from, state) do
    {:reply, state.cache_size, state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum()
    {:reply, total, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Can't touch this! #{inspect(message)}")
    {:noreply, state}
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

# {:ok, pid} = PledgeServer.start()

# IO.inspect(PledgeServer.create_pledge("larry", 10))
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))

# IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
