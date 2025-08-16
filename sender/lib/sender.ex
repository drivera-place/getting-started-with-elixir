defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @doc """
  Send email.

  ## Examples

      iex> Sender.send_email("test@example.com")
      :ok

  """
  def send_email(email) do
    Process.sleep(30_000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  def notify_all(emails) do
    Enum.each(emails, fn email ->
      Task.start(fn ->
        send_email(email)
      end)
    end)
  end

end
