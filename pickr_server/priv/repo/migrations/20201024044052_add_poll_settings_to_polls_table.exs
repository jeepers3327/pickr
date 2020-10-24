defmodule Pickr.Repo.Migrations.AddPollSettingsToPollsTable do
  use Ecto.Migration

  def change do
    alter table(:polls) do
      add :allow_multiple_choice, :boolean, default: false, null: false
      add :allow_single_vote_only, :boolean, default: false, null: false
    end
  end
end
