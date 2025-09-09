defmodule Protocols do
  defprotocol Codecs do
    def parse(data)
  end
end
