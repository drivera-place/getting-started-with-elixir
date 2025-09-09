defmodule Teltonika.TCPCodec8.Gps do
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
