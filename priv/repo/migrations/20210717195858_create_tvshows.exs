defmodule Previously.Repo.Migrations.CreateTvshows do
  use Ecto.Migration

  def change do
    create table(:tvshows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :poster, :string
      add :title, :string
      add :imdb_id, :string

      timestamps()
    end

    create unique_index(:tvshows, [:imdb_id])
  end
end
