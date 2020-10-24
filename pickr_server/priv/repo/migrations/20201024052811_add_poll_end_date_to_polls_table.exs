defmodule Pickr.Repo.Migrations.AddPollEndDateToPollsTable do
  use Ecto.Migration

  def change do
    alter table(:polls) do
      add :end_date, :date, default: fragment("now()")
    end
  end
end
