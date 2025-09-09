defmodule Protocols do
  defprotocol Codecs do
    def parse(data)
    def read_imei(data)
    def accept_client_data(_)
    def deny_client_data(_)
  end
end
