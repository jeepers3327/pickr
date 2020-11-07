defmodule Pickr.PollsTest do
  use Pickr.DataCase

  alias Pickr.Polls

  describe "polls" do
    alias Pickr.Polls.Poll

    @valid_attrs %{
      question: "some question",
      options: [
        %{value: "test a"},
        %{value: "test b"},
        %{value: "test c"}
      ]
    }
    @invalid_attrs %{question: nil}

    def poll_fixture(attrs \\ %{}) do
      {:ok, poll} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Polls.create_poll()

      poll
    end


    test "get_poll!/1 returns the poll with given id" do
      poll = poll_fixture()
      assert Polls.get_poll(poll.id) == poll
    end

    test "create_poll/1 with valid data creates a poll" do
      assert {:ok, %Poll{} = poll} = Polls.create_poll(@valid_attrs)
      assert poll.question == "some question"
    end

    test "create_poll/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Polls.create_poll(@invalid_attrs)
    end

  end
end
