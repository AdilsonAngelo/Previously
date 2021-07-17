defmodule Previously.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration

  def change do
    create table(:episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :season, :integer
      add :number, :integer
      add :release, :date
      add :title, :string
      add :watched, :boolean
      add :imdb_id, :string

      timestamps()
    end

    create unique_index(:episodes, [:imdb_id])
  end
end
