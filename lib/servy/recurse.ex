defmodule Servy.Recurse do
    def loopy([head | tail]) do
      IO.puts "Head: #{head} Tail: #{inspect(tail)}"
      loopy(tail)
    end
    
    def loopy([]), do: IO.puts "Done!"
    
    def sum([head | tail], total) do
        sum(tail, total + head)
    end 

    def sum([], total), do: IO.puts "Sum of entire totals inside list: #{total}"

    def triple([head | tail]) do
        [head * 3 | triple(tail)]
    end

    def triple([]), do: []

    def my_map(list, anonimous_function) do
        Enum.map(list, anonimous_function)
    end

  end