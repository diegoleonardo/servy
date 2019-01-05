defmodule Servy.Handler do
  @moduledoc """
      Handles HTTP requests.
  """

  @pages_path Path.expand("pages/", __DIR__)

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.SensorController
  alias Servy.PledgeController
  alias Servy.FourOhFourCounter, as: Counter

  # Import entire module
  # import Servy.Plugins 

  # Import only some functions of a module
  # The number in sequence imported function's, it's a number of parameters (Arity)
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: :functions

  @doc """
      Transforms the request into a response.
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/404s"} = conv) do
    counters = Counter.get_counts()
    %{conv | status: 200, resp_body: inspect(counters)}
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/pledges/new"} = conv) do
    PledgeController.new(conv)
  end

  def route(%Conv{method: "POST", path: "/pledges"} = conv) do
    PledgeController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/snapshots"} = conv) do
    SensorController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/explode"}) do
    raise "Booom!"
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer() |> :timer.sleep()
    %{conv | status: 200, resp_body: "Awaked!"}
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers, Elephants"}
  end

  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "POST", path: "/api/bears"} = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read()
    |> handle_file(conv)
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def emojify(%Conv{status: 200} = conv) do
    emojies = String.duplicate("🎉", 5)
    body = emojies <> "\n" <> conv.resp_body <> "\n" <> emojies

    %{conv | resp_body: body}
  end

  def emojify(%Conv{} = conv), do: conv

  def put_content_length(%Conv{resp_headers: resp_headers, resp_body: resp_body} = conv) do
    headers = Map.put(resp_headers, "Content-Length", byte_size(resp_body))
    %{conv | resp_headers: headers}
  end

  def format_response_headers(conv) do
    for {key, value} <- conv.resp_headers do
      "#{key}: #{value}\r"
    end
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end
end
