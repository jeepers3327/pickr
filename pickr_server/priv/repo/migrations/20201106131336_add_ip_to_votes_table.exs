defmodule Pickr.Repo.Migrations.AddIpToVotesTable do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :ip, :string
    end
  end
end
