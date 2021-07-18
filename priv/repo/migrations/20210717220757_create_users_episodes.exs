defmodule Previously.Repo.Migrations.CreateUsersEpisodes do
  use Ecto.Migration

  def change do
    create table(:users_episodes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all)
      add :episode_id, references(:episodes, type: :uuid, on_delete: :delete_all)
    end

    create unique_index(:users_episodes, [:user_id, :episode_id])
  end
end
