defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear
  import Servy.View, only: [render: 3]

  def index(conv) do
    bears =
      Wildthings.list_bears()
      # THIS(&) IS A SHORTCUT TO ANONYNOUS FUNCTIONS
      |> Enum.sort(&Bear.order_asc_by_name(&1, &2))

    # |> Enum.map(&bear_item/1)
    # |> Enum.join

    render(conv, "index.eex", bears: bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, "show.eex", bear: bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{conv | status: 201, resp_body: "Create a #{type} bear named #{name}!"}
  end

  def delete(conv, %{"id" => id}) do
    %{conv | status: 403, resp_body: "Bear #{id} must never be deleted!"}
  end
end
