defmodule Servy.SensorController do
    alias Servy.VideoCam
    alias Servy.Tracker
    import Servy.View, only: [render: 3]
    
    def index(conv) do
        task4 = Task.async(fn -> Tracker.get_location("bigfoot") end)

        task1 = Task.async(fn -> VideoCam.get_snapshot("cam-1") end)
        task2 = Task.async(fn -> VideoCam.get_snapshot("cam-2") end)
        task3 = Task.async(fn -> VideoCam.get_snapshot("cam-3") end)

        snapshot1 = Task.await(task1)
        snapshot2 = Task.await(task2)
        snapshot3 = Task.await(task3)
        where_is_bigfoot = Task.await(task4)
        
        IO.inspect where_is_bigfoot

        snapshots = [snapshot1, snapshot2, snapshot3]

        render(conv, "sensors.eex", sensors: snapshots, location: where_is_bigfoot)
    end
end