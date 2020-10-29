defmodule PickrWeb.PollView do
  use PickrWeb, :view
  alias PickrWeb.PollView

  def render("no_result.json", %{id: id}) do
    %{message: "No poll existed for the poll id #{id}."}
  end

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll.json")}
  end

  def render("vote_exist.json", %{has_vote: has_vote}) do
    %{already_voted: has_vote}
  end

  def render("poll.json", %{poll: poll}) do
    %{id: poll.id,
      question: poll.question,
      end_date: poll.end_date,
      allow_multiple_choice: poll.allow_multiple_choice,
      single_vote_only: poll.allow_single_vote_only,
      options: render_many(poll.options, PollView, "poll_option.json", as: :option)
    }
  end

  def render("poll_result.json", %{poll: poll}) do
    %{id: poll.id,
      question: poll.question,
      total_votes: poll.total_votes,
      options: render_many(poll.options, PollView, "poll_option_result.json", as: :option)
    }
  end

  def render("poll_option.json", %{option: option}) do
    %{
      id: option.id,
      value: option.value
    }
  end

  def render("poll_option_result.json", %{option: option}) do
    %{
      id: option.id,
      value: option.value,
      votes: option.votes
    }
  end


end
