defmodule Servy.PledgeServer do
  alias HTTPoison

  @name :pledge_server

  # CLIENTE INTERFACE FUNCTIONS
  def start(initial_state \\ []) do
    IO.puts("Starting the pledge server...")
    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    Process.register(pid, @name)
    pid
  end

  def create_pledge(name, amount) do
    IO.puts("name: #{name}")
    IO.puts("amount: #{amount}")

    send(@name, {self(), :create_pledge, name, amount})

    receive do
      {:response, status} -> status
    end
  end

  def recent_pledges do
    send(@name, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged do
    send(@name, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # SERVER INTERFACE FUNCTIONS
  def listen_loop(state) do
    receive do
      {sender, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)

        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]
        send(sender, {:response, id})
        listen_loop(new_state)

      {sender, :recent_pledges} ->
        send(sender, {:response, state})
        listen_loop(state)

      {sender, :total_pledged} ->
        total = Enum.map(state, &elem(&1, 1)) |> Enum.sum()
        send(sender, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  def send_pledge_to_service(name, amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    url = "https://putsreq.com/gSjF80g1XBYIxaUak32L"
    body = ~s({"name": #{name}, "amount": #{amount}})
    headers = [{"Content-Type", "application/json"}]

    HTTPoison.post(url, body, headers)

    {:ok, "pledge-#{:rand.uniform(1000)}"}
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
