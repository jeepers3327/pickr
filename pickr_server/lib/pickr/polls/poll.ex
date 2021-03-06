defmodule Pickr.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field :question, :string
    has_many :options, Pickr.Polls.Option

    field :allow_multiple_choice, :boolean, default: false
    field :allow_single_vote_only, :boolean, default: false
    field :end_date, :date, default: Date.utc_today()
    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:question, :allow_multiple_choice, :allow_single_vote_only, :end_date])
    |> cast_assoc(:options, required: true)
    |> validate_required([:question])
  end
end
