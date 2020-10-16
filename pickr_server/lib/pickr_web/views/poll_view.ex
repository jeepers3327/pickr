defmodule PickrWeb.PollView do
  use PickrWeb, :view
  alias PickrWeb.PollView

  def render("index.json", %{polls: polls}) do
    %{data: render_many(polls, PollView, "poll.json")}
  end

  def render("show.json", %{poll: poll}) do
    %{data: render_one(poll, PollView, "poll.json")}
  end

  def render("poll.json", %{poll: poll}) do
    %{id: poll.id,
      question: poll.question}
  end

  def render("poll_result.json", %{poll: poll}) do
    %{id: poll.id,
      question: poll.question,
      options: render_many(poll.options, PollView, "option.json", as: :option)
    }
  end

  def render("option.json", %{option: option}) do
    %{
      id: option.id,
      value: option.value,
      votes: option.votes
    }
  end
end
