defmodule Servy.Timer do
  use Stopwatch

  def remind(reminder, seconds) do
    spawn(fn ->
      :timer.sleep(seconds * 1000)
      IO.puts(reminder)
    end)
  end

  def loop_timer() do
    watch = Watch.new()
    for x <- 1..200_000, do: IO.puts(x * 10)
    # remember, immutability!
    watch = Watch.stop(watch)
    # 16839.722, number of milliseconds elapsed
    'Spended time: #{Watch.get_total_time(watch)} ms'
  end

  def map_reduce_problem(n) do
    pid = spawn(fn -> process_map(n) end)
    pid
  end

  def process_map(n) do
    watch = Watch.new()
    IO.puts(Enum.reduce(1..n, 0, fn x, acc -> acc + x end))
    # remember, immutability!
    watch = Watch.stop(watch)
    # 16839.722, number of milliseconds elapsed
    IO.puts('Spended time: #{Watch.get_total_time(watch)} ms')
  end
end
