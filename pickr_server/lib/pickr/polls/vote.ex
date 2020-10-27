defmodule Pickr.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    belongs_to :poll, Pickr.Polls.Poll
    belongs_to :option, Pickr.Polls.Option

    field :allow_single_vote_only, :boolean, virtual: true, default: false
    field :allow_multiple_choice, :boolean, virtual: true, default: false
    field :options, {:array, :map}, virtual: true
    field :ip, :string

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:poll_id, :option_id, :ip])
    |> foreign_key_constraint(:option_id)
    |> foreign_key_constraint(:poll_id)
    |> validate_required([:poll_id, :option_id])
  end

  def cast_vote_changeset(vote, attrs) do
    vote
      |> cast(attrs, [:poll_id, :ip, :options])
      |> put_poll_settings()
      |> validate_required([:options])
      |> maybe_allow_multiple_choice(attrs)
      |> vote_exist_check()
  end

  defp maybe_allow_multiple_choice(%Ecto.Changeset{changes: %{allow_multiple_choice: multi}} = changeset, %{options: options}) when multi == false do
    if length(options) > 1 do
      add_error(changeset, :options, "One option is allowed!")
    end
   end

  defp maybe_allow_multiple_choice(changeset, _attrs), do: changeset

  defp vote_exist_check(%Ecto.Changeset{changes: %{allow_single_vote_only: single_vote, ip: ip, poll_id: id}} = changeset) when single_vote == true do
    case Pickr.Polls.has_vote?(id, ip) do
      false -> add_error(changeset, :allow_single_vote_only, "You already voted in this poll!")
      true -> changeset
    end
  end

  defp vote_exist_check(changeset), do: changeset

  defp put_poll_settings(%Ecto.Changeset{changes: %{poll_id: id}} = changeset) do
    case Pickr.Polls.get_poll(id) do
      nil -> add_error(changeset, :poll_id, "Poll id does not exist!")
      poll ->
        %{allow_multiple_choice: multi, allow_single_vote_only: single_vote} = poll
        put_change(changeset, :allow_multiple_choice, multi)
        put_change(changeset, :allow_single_vote_only, single_vote)
    end
  end



end
