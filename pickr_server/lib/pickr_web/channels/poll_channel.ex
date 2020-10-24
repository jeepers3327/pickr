defmodule PickrWeb.PollChannel do
  use PickrWeb, :channel

  @impl true
  def join("poll:" <> id, _payload, socket) do
    {:ok, Pickr.Polls.get_poll_results(id), socket }
  end

  @impl true
  def handle_in("new_vote", payload, socket) do
    broadcast!(socket, "updated_result", Pickr.Polls.get_poll_results(payload))
    {:noreply, socket}
  end


end
