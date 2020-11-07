defmodule PickrWeb.PollController do
  use PickrWeb, :controller

  alias Pickr.Polls
  alias Pickr.Polls.Poll

  action_fallback PickrWeb.FallbackController

  def create(conn, %{"poll" => poll_params}) do
    with {:ok, %Poll{} = poll} <- Polls.create_poll(poll_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.poll_path(conn, :show, poll))
      |> render("show.json", poll: poll)
    end
  end

  def show(conn, %{"id" => id}) do
    case Polls.get_poll(id) do
      nil ->
        {:error, :not_found}
      poll ->
        render(conn, "show.json", poll: poll)
    end
  end

  def cast_vote(conn, %{"vote" => vote_params}) do
    with  {:ok, _vote} <- Polls.cast_vote(vote_params) do
      conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, "Your vote has been casted!")
    end
  end

  def get_poll_result(conn, %{"id" => id}) do
    poll = Polls.get_poll_results(id)
    render(conn, "poll_result.json", poll: poll)
  end

  def get_vote_exist(%Plug.Conn{params: params} = conn, _params) do
    vote_exist = Polls.check_vote_exist(params["id"], params["ip"])
    render(conn, "vote_exist.json", has_vote: vote_exist)
  end
end
