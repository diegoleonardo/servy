defmodule PledgedServerTest do
  use ExUnit.Case
  alias Servy.PledgeServer

  setup do
    {:ok, pid} = PledgeServer.start()

    on_exit(fn ->
      Process.exit(pid, :kill)
    end)
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

  test "should assert that pre-fetch pledges happens" do
    pledges = PledgeServer.recent_pledges()
    assert pledges == [{"wilma", 15}, {"fred", 25}]
  end

  test "should assert that cache_size has default value 3" do
    cache_size = PledgeServer.get_cache_size()
    assert cache_size == 3
  end

  test "should assert that cache_size is set to 4" do
    PledgeServer.set_cache_size(4)
    cache_size = PledgeServer.get_cache_size()
    assert cache_size == 4
  end
end
