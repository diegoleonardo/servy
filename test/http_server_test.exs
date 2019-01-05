defmodule HttpServerTest do
    use ExUnit.Case

    alias Servy.HttpServer
    import HTTPoison, only: [get: 1]

    setup_all do
        spawn(HttpServer, :start, [4000])
        :ok
    end

    test "Make a request to Http Server" do

        url = "http://localhost:4000/wildthings"

        [1..5]
        |> Enum.map(fn(_) -> Task.async(fn -> get url end) end)
        |> Enum.map(&Task.await/1)
        |> Enum.map(&assert_successful_response/1)

        # JEITO TOSCO E VERBOSO:
        # task1 = Task.async(fn -> get "http://localhost:4000/wildthings" end)
        # task2 = Task.async(fn -> get "http://localhost:4000/wildthings" end)
        # task3 = Task.async(fn -> get "http://localhost:4000/wildthings" end)
        # task4 = Task.async(fn -> get "http://localhost:4000/wildthings" end)
        # task5 = Task.async(fn -> get "http://localhost:4000/wildthings" end)

        # {:ok, request1} = Task.await(task1)
        # {:ok, request2} = Task.await(task2)
        # {:ok, request3} = Task.await(task3)
        # {:ok, request4} = Task.await(task4)
        # {:ok, request5} = Task.await(task5)

        # spawn(fn -> send(pid, {:result, get "http://localhost:4000/wildthings"}) end)
        # spawn(fn -> send(pid, {:result, get "http://localhost:4000/wildthings"}) end)
        # spawn(fn -> send(pid, {:result, get "http://localhost:4000/wildthings"}) end)
        # spawn(fn -> send(pid, {:result, get "http://localhost:4000/wildthings"}) end)
        # spawn(fn -> send(pid, {:result, get "http://localhost:4000/wildthings"}) end)
        
        # {:ok, request1} = receive do {:result, response} -> response end
        # {:ok, request2} = receive do {:result, response} -> response end
        # {:ok, request3} = receive do {:result, response} -> response end
        # {:ok, request4} = receive do {:result, response} -> response end
        # {:ok, request5} = receive do {:result, response} -> response end

        # expected_response = "Bears, Lions, Tigers, Elephants"

        # assert request1.status_code == 200
        # assert request2.status_code == 200
        # assert request3.status_code == 200
        # assert request4.status_code == 200
        # assert request5.status_code == 200

        # assert request1.body == expected_response
        # assert request2.body == expected_response
        # assert request3.body == expected_response
        # assert request4.body == expected_response
        # assert request5.body == expected_response
    end

    test "Make a request multiple pages to Http Server" do

        urls = [
            "http://localhost:4000/wildthings", 
            "http://localhost:4000/bears", 
            "http://localhost:4000/api/bears", 
            "http://localhost:4000/bears/1",
            "http://localhost:4000/hibernate/200"
        ]

        urls
        |> Enum.map(fn(url) -> Task.async(fn -> get url end) end)
        |> Enum.map(&Task.await/1)
        |> Enum.map(&assert_response_is_status_ok/1)
    end

    defp assert_successful_response({:ok, response} = request) do
        assert assert_response_is_status_ok(request)
        assert response.body == "Bears, Lions, Tigers, Elephants"
    end

    defp assert_response_is_status_ok({:ok, response}) do
        assert response.status_code == 200
    end

end