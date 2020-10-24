defmodule Pickr.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    belongs_to :poll, Pickr.Polls.Poll
    belongs_to :option, Pickr.Polls.Option

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:poll_id, :option_id])
    |> foreign_key_constraint(:option_id)
    |> foreign_key_constraint(:poll_id)
    |> validate_required([:poll_id, :option_id])
  end
end
