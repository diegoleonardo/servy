defmodule Servy.FourOhFourCounter do
  @name :four_oh_four_conter

  def start(initial_state \\ []) do
    IO.puts("Starting the Four Oh Four Counter...")
    pid = spawn(__MODULE__, :loop_counter, [initial_state])
    Process.register(pid, @name)
    pid
  end

  def loop_counter(state) do
    receive do
      {sender, :bump_count, "/nessie"} ->
        state = ["/nessie" | state]
        send(sender, {:result, "Count nessie ++"})
        loop_counter(state)

      {sender, :bump_count, "/bigfoot"} ->
        state = ["/bigfoot" | state]
        send(sender, {:result, "Count bigfoot ++"})
        loop_counter(state)

      {sender, :get_count, element} ->
        total = Enum.count(state, fn x -> x == element end)
        send(sender, {:result, total})
        loop_counter(state)

      {sender, :get_counts} ->
        counters =
          Enum.uniq(state)
          |> Enum.map(fn x -> {x, Enum.count(state, fn y -> y == x end)} end)
          |> Map.new()

        send(sender, {:result, counters})
        loop_counter(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        loop_counter(state)
    end
  end

  def bump_count(url) do
    send(@name, {self(), :bump_count, url})

    receive do
      {:result, value} -> value
    end
  end

  def get_count(url) do
    send(@name, {self(), :get_count, url})

    receive do
      {:result, total} -> total
    end
  end

  def get_counts() do
    send(@name, {self(), :get_counts})

    receive do
      {:result, counters} -> counters
    end
  end
end
