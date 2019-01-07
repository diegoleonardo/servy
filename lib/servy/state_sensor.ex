defmodule Servy.StateSensor do
  defstruct sensor: %{}, refresh_interval: :timer.minutes(60)
end
