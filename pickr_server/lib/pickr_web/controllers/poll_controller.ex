defmodule PickrWeb.PollController do
  use PickrWeb, :controller

  alias Pickr.Polls
  alias Pickr.Polls.Poll

  action_fallback PickrWeb.FallbackController

  def index(conn, _params) do
    polls = Polls.list_polls()
    render(conn, "index.json", polls: polls)
  end

  def create(conn, %{"poll" => poll_params}) do
    with {:ok, %Poll{} = poll} <- Polls.create_poll(poll_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.poll_path(conn, :show, poll))
      |> render("show.json", poll: poll)
    end
  end

  def show(conn, %{"id" => id}) do
    poll = Polls.get_poll!(id)
    render(conn, "show.json", poll: poll)
  end

  def update(conn, %{"id" => id, "poll" => poll_params}) do
    poll = Polls.get_poll!(id)

    with {:ok, %Poll{} = poll} <- Polls.update_poll(poll, poll_params) do
      render(conn, "show.json", poll: poll)
    end
  end

  def delete(conn, %{"id" => id}) do
    poll = Polls.get_poll!(id)

    with {:ok, %Poll{}} <- Polls.delete_poll(poll) do
      send_resp(conn, :no_content, "")
    end
  end

  def cast_vote(conn, %{"vote" => vote_params}) do
    with  {:ok, _vote} <- Polls.cast_vote(vote_params) do
      send_resp(conn, :no_content, "")
    end
  end

  def get_poll_result(conn, %{"id" => id}) do
    poll = Polls.get_poll_results(id)
    render(conn, "poll_result.json", poll: poll)
  end
end
