defmodule Previously.Repo.Migrations.EpisodeBelongsToTvshow do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :tvshow_id, references(:tvshows, type: :uuid, on_delete: :delete_all)
    end

    create index(:episodes, [:tvshow_id])
  end
end
