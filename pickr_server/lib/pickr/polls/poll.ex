defmodule Pickr.Polls.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field :question, :string

    has_many :options, Pickr.Polls.Option
    timestamps()
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:question])
    |> cast_assoc(:options, required: true)
    |> validate_required([:question])
  end
end
