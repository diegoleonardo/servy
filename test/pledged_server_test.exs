defmodule PledgedServerTest do
  use ExUnit.Case
  alias Servy.PledgeServer

  setup_all do
    PledgeServer.start()
    :ok
  end

  test "should assert that the server caches only the 3 most recent pledges" do
    PledgeServer.create_pledge("Diego", 10)
    PledgeServer.create_pledge("Leonardo", 20)
    PledgeServer.create_pledge("Pantoja", 30)
    PledgeServer.create_pledge("Santos", 40)

    pledges = PledgeServer.recent_pledges()

    assert pledges == [{"Santos", 40}, {"Pantoja", 30}, {"Leonardo", 20}]
  end

  test "should assert totals of amounts" do
    PledgeServer.create_pledge("Diego", 10)
    PledgeServer.create_pledge("Leonardo", 20)
    PledgeServer.create_pledge("Pantoja", 30)
    PledgeServer.create_pledge("Santos", 40)

    total = PledgeServer.total_pledged()

    assert total == 90
  end
end
