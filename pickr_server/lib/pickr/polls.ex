defmodule Pickr.Polls do
  @moduledoc """
  The Polls context.
  """

  import Ecto.Query, warn: false
  alias Pickr.Repo

  alias Pickr.Polls.{Poll, Vote}

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    Repo.all(Poll) |> Repo.preload(:options)
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll!(123)
      %Poll{}

      iex> get_poll!(456)
      ** (Ecto.NoResultsError)

  """
  def get_poll(id), do: Repo.get(Poll, id) |> Repo.preload(:options)

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(attrs \\ %{}) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})
      {:ok, %Poll{}}

      iex> update_poll(poll, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  def cast_vote(attrs) do
    vote = Vote.cast_vote_changeset(%Vote{}, attrs)
    case vote.valid? do
      true ->
            result = Repo.transaction(fn ->
                      Enum.map(attrs["options"], fn params ->
                        vote_params = Map.put_new(params, "ip", attrs["ip"])
                        changeset = Vote.changeset(%Vote{}, vote_params)
                        Repo.insert(changeset)
                      end)
                    end)

            case result do
              {:ok, list} -> {:ok, list}
              {:error, _failed_operation, _failed_value, _changes_so_far} -> {:error, :bad_request}
            end
      false -> {:error, vote}
    end
  end

  def get_poll_results(id) do
    poll = get_poll(id)
    votes =
      case get_votes_per_poll(id) do
        [] -> set_default_votes(poll.options)
        result -> append_votes_with_defaults(poll.options, result)
      end

    total_votes = get_total_votes(votes)
    options = append_votes_to_options(poll.options, votes, total_votes)

    %{id: poll.id, question: poll.question, options: options, total_votes: total_votes}
  end

  defp convert_to_percentage(vote, _total_vote) when vote == 0, do: 0

  defp convert_to_percentage(vote, total_vote) do
    vote / total_vote * 100 |> Float.round(1)
  end

  defp append_votes_to_options(poll_options, result_poll_options, total_votes) do
    for %{id: id} = x <- poll_options, %{option_id: o_id} = y <- result_poll_options, id == o_id do
      %{id: x.id, value: x.value, votes: convert_to_percentage(y.votes, total_votes)}
    end
  end

  defp get_votes_per_poll(id) do
    Vote |> where([v], v.poll_id == ^id) |> group_by([v], v.option_id) |> select([v], %{option_id: v.option_id, votes: count(v.id)})  |> Repo.all
  end

  defp get_total_votes(vote_result) do
    Enum.reduce(vote_result, 0, fn(%{votes: vote}, total_vote) ->
      total_vote + vote
    end)
  end

  defp append_votes_with_defaults(options, result) do
    Enum.map(options, fn %{id: id} ->
      case Enum.find(result, &(&1.option_id == id)) do
        nil -> %{option_id: id, votes: 0}
        option -> option
      end
    end)
  end

  defp set_default_votes(options)  do
    Enum.map(options, fn option ->
      %{option_id: option.id, votes: 0}
    end )
  end

  def check_vote_exist(id, ip) do
    poll = Repo.get(Poll, id)
    case poll do
      nil -> {:error, :not_found}
      poll ->
        if poll.allow_single_vote_only do
          case has_vote?(id, ip) do
            true -> true
            false -> false
          end
        end
    end
  end


  def has_vote?(id, ip) do
    query = Vote |> where([v], v.poll_id == ^id) |> where([v], v.ip == ^ip) |> select([v], count(v))
    case Repo.all(query) do
      [0] -> false
      _ -> true
    end
  end

end
