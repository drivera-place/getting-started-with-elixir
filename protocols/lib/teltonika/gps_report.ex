defmodule Teltonika.Gps do
  defstruct [
    :priority,
    :timestamp,
    :latitude,
    :longitude,
    :altitude,
    :angle,
    :satellites,
    :speed
  ]
end
