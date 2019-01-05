# ERLANG CODE
# client() ->
#     SomeHostInNet = "localhost", % to make it runnable on one machine
#     {ok, Sock} = gen_tcp:connect(SomeHostInNet, 5678, 
#                                  [binary, {packet, 0}]),
#     ok = gen_tcp:send(Sock, "Some Data"),
#     ok = gen_tcp:close(Sock).

defmodule Servy.HttpClient do
    def send_request(request) do
        opts = [:binary, packet: :raw, active: false]

        case :gen_tcp.connect('localhost', 4000, opts) do
          {:ok, socket} ->
            :ok = :gen_tcp.send(socket, request)
            {:ok, response} = :gen_tcp.recv(socket, 0)
            :ok = :gen_tcp.close(socket)
            response
          {:error, reason} ->
            IO.puts "TCP connection error: #{inspect reason}"
        end
    end
    
end