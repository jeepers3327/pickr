defmodule PickrWeb.PollViewTest do
  use PickrWeb.ConnCase, async: true

  import Phoenix.View
  alias Pickr.Polls

  @create_attrs %{
    question: "some question",
    options: [
      %{value: "test a"},
      %{value: "test b"},
      %{value: "test c"}
    ]
  }

  test "renders no_result.json" do
    assert render(PickrWeb.PollView, "no_result.json", [id: 1]) == %{message: "No poll existed for the poll id 1."}
  end


  test "renders show.json" do
    {:ok, new_poll} = Polls.create_poll(@create_attrs)
    %{data: poll} = render(PickrWeb.PollView, "show.json", [poll: Polls.get_poll(new_poll.id)])
    options = for option <- new_poll.options do
      %{id: option.id, value: option.value}
    end
    assert poll == %{
      id: new_poll.id,
      question: new_poll.question,
      options: options,
      single_vote_only: new_poll.allow_single_vote_only,
      allow_multiple_choice: new_poll.allow_multiple_choice,
      end_date: new_poll.end_date
    }
  end

  test "render poll_option_result.json" do

  end


end
