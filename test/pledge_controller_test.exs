defmodule PledgeControllerTest do
  use ExUnit.Case
  alias Servy.PledgeServer
  alias Servy.HttpServer
  alias HTTPoison
  alias Poison

  @url "http://localhost:4000/pledges"

  test "should be inserted new pledges in request" do
    {:ok, pid} = PledgeServer.start()
    spawn(HttpServer, :start, [4000])

    header = [{"Content-Type", "application/json"}]
    body1 = ~s({"name": "larry", "amount": "100"})
    body2 = ~s({"name": "moe", "amount": "200"})
    body3 = ~s({"name": "curly", "amount": "300"})
    body4 = ~s({"name": "daisy", "amount": "400"})
    body5 = ~s({"name": "grace", "amount": "500"})

    HTTPoison.post(@url, body1, header)
    HTTPoison.post(@url, body2, header)
    HTTPoison.post(@url, body3, header)
    HTTPoison.post(@url, body4, header)
    HTTPoison.post(@url, body5, header)

    {:ok, response} = HTTPoison.get(@url)

    expected_response = """
    <h1>All The Pledges</h1>

    <ul>

        <li> grace - 500 </li>

        <li> daisy - 400 </li>

        <li> curly - 300 </li>

    </ul>
    """

    assert remove_whitespace(response.body) == remove_whitespace(expected_response)
  end

  defp remove_whitespace(text) do
    String.replace(text, ~r{\s}, "")
  end
end
