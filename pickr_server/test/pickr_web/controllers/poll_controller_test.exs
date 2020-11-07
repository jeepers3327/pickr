defmodule PickrWeb.PollControllerTest do
  use PickrWeb.ConnCase

  alias Pickr.Polls
  alias Pickr.Polls.Poll

  @create_attrs %{
    question: "some question",
    options: [
      %{value: "test a"},
      %{value: "test b"},
      %{value: "test c"}
    ]
  }
  @single_vote_poll_attrs %{
    question: "some question",
    allow_single_vote_only: true,
    options: [
      %{value: "test a"},
      %{value: "test b"},
      %{value: "test c"}
    ]
  }
  @invalid_attrs %{question: nil}
  @ip "192.168.1.1"

  def fixture(:poll) do
    {:ok, poll} = Polls.create_poll(@create_attrs)
    poll
  end

  def fixture(:single_poll) do
    with {:ok, poll} <- Polls.create_poll(@single_vote_poll_attrs),
         {:ok, poll} <- Polls.get_poll(poll.id)  do
          poll
     end
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create poll" do
    test "renders poll when data is valid", %{conn: conn} do
      conn = post(conn, Routes.poll_path(conn, :create), poll: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.poll_path(conn, :show, id))

      assert %{
               "id" => id,
               "question" => "some question"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.poll_path(conn, :create), poll: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "cast vote" do
    setup [:create_poll]

    test "return 200 reponse when vote is valid", %{conn: conn, poll: %Poll{id: id}} do
      conn = get(conn, Routes.poll_path(conn, :show, id))
      assert %{"id" => id, "options" => options} = json_response(conn, 200)["data"]
      option = hd(options)
      vote_params = %{"poll_id" => id, "options" => [%{"poll_id" =>  id, "option_id" => option["id"]}]}

      conn = post(conn, Routes.poll_path(conn, :cast_vote, id), vote: vote_params)
      assert response(conn, 200) == "Your vote has been casted!"
    end

    test "return 400 reponse when vote is not valid", %{conn: conn, poll: %Poll{id: id}} do
      vote_params = %{"poll_id" => id, "options" => [%{"poll_id" =>  id, "option_id" => 1}]}

      conn = post(conn, Routes.poll_path(conn, :cast_vote, id), vote: vote_params)
      assert response(conn, 400) == "An error occured!. Please check the data sent."
    end
  end

  describe "retrieve poll" do
    setup [:create_poll]

    test "return poll when id exist", %{conn: conn, poll: %Poll{id: id, question: question}} do
      conn = get(conn, Routes.poll_path(conn, :show, id))
      json = json_response(conn, 200)["data"]
      assert json["id"] == id
      assert json["question"] == question
    end

    test "return error response when id does not exist", %{conn: conn} do
      conn = get(conn, Routes.poll_path(conn, :show, 1))
      assert json_response(conn, 404) == "Not Found"
    end

  end

  describe "get poll result" do
    setup [:get_poll]

    test "retrieve poll result without votes", %{conn: conn, poll: poll} do
      conn = get(conn, Routes.poll_path(conn, :get_poll_result, poll.id))
      json = json_response(conn, 200)
      options = for option <- poll.options  do
        %{"id" => option.id, "value" => option.value, "votes" => 0}
      end
      assert json == %{
        "id" => poll.id,
        "question" => poll.question,
        "options" => options,
        "total_votes" => 0
      }
    end
  end

  describe "check if vote exist" do
    setup [:create_single_vote_poll]

    test "check vote exist if poll is single vote", %{conn: conn, poll: poll, option_1: option_1} do
      conn = get(conn, Routes.poll_path(conn, :get_vote_exist, poll.id, ip: @ip))
      assert json_response(conn, 200) == %{"already_voted" => false}

      vote_params = %{"poll_id" => poll.id, "ip" => @ip, "options" => [%{"poll_id" =>  poll.id, "option_id" => option_1.id}]}
      conn = post(conn, Routes.poll_path(conn, :cast_vote, poll.id), vote: vote_params)
      assert response(conn, 200) == "Your vote has been casted!"

      conn = get(conn, Routes.poll_path(conn, :get_vote_exist, poll.id, ip: @ip))
      IO.inspect(json_response(conn, 200))
      assert json_response(conn, 200) == %{"already_voted" => true}
    end
  end

  defp create_poll(_) do
    poll = fixture(:poll)
    %{poll: poll}
  end

  defp get_poll(_) do
      poll_data = fixture(:poll)
      poll = Polls.get_poll(poll_data.id)
      %{poll: poll}
  end

  defp create_single_vote_poll(_) do
    poll = fixture(:single_poll)
    option_1 = Enum.at(poll.options, 0)
    option_2 = Enum.at(poll.options, 1)
    option_3 = Enum.at(poll.options, 2)
    %{poll: poll, option_1: option_1, option_2: option_2, option_3: option_3}
  end
end
