defmodule PickrWeb.PollChannelTest do
  use PickrWeb.ChannelCase

  @valid_attrs %{
    question: "some question",
    options: [
      %{value: "test a"},
      %{value: "test b"},
      %{value: "test c"}
    ]
  }

  setup do
   {:ok, poll} =  Pickr.Polls.create_poll(@valid_attrs)
   {:ok, _, socket} =
    PickrWeb.UserSocket
    |> socket("poll_id", %{})
    |> subscribe_and_join(PickrWeb.PollChannel, "poll:" <> Integer.to_string(poll.id))
    %{socket: socket, poll: poll}
  end

  test "new vote is pushed to the client", %{socket: socket, poll: poll} do
    result = Pickr.Polls.get_poll_results(poll.id)
    broadcast_from! socket, "updated_result", result
    assert_push "updated_result", result
  end

  test "new vote is broadcasted", %{socket: socket, poll: poll} do
    id = Map.get(poll, :id)
    push(socket, "new_vote", id)
    _result = Pickr.Polls.get_poll_results(id)
    assert_broadcast "updated_result", result
  end
end
