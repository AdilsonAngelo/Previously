defmodule Previously.Episodes do
  @moduledoc """
  The Episodes context.
  """

  require Ecto.UUID
  import Ecto.Query, warn: false
  alias Previously.Repo

  alias Previously.Episodes.Episode
  alias Previously.TVShows
  alias Previously.IMDb.IMDbService

  def list_episodes(user_id, tvshow_id) do
    user_id
    |> query_by_user_id_and_tvshow_id(tvshow_id)
    |> Repo.all()
  end

  def get_episode!(user_id, tvshow_id, id) do
    user_id
    |> query_by_user_id_and_tvshow_id(tvshow_id)
    |> Repo.get!(id)
  end

  def get_by_imdb_id(imdb_id), do: Repo.get_by(Episode, imdb_id: imdb_id)

  def get_by_imdb_id!(imdb_id), do: Repo.get_by!(Episode, imdb_id: imdb_id)

  def mark_episode(user, ep_code) do
    try_episode =
      with nil <- get_by_imdb_id(ep_code) do
        fetch_and_save(ep_code)
      end

    case try_episode do
      %Episode{} = episode ->
        episode
        |> Repo.preload(:users)
        |> Ecto.Changeset.change()
        |> Ecto.Changeset.put_assoc(:users, [user])
        |> Repo.update()

      nil ->
        {:error, :not_found, "episode not found"}
    end
  end

  def unmark_episode(user_id, ep_code) do
    with %Episode{} = episode <- get_by_imdb_id!(ep_code) do
      query =
        from ue in "users_episodes",
          where:
            ue.user_id == ^Ecto.UUID.dump!(user_id) and
              ue.episode_id == ^Ecto.UUID.dump!(episode.id)

      Repo.delete_all(query)
    end
  end

  def fetch_and_save(ep_code) do
    case IMDbService.fetch_episode(ep_code) do
      {:ok, ep_attrs, tvshow_code} ->
        tvshow =
          with nil <- TVShows.get_by_imdb_id(tvshow_code) do
            TVShows.fetch_and_save(tvshow_code)
          end

        {:ok, episode} =
          ep_attrs
          |> Map.put(:tvshow_id, tvshow.id)
          |> create_episode()

        episode

      {:error, _, _} ->
        nil
    end
  end

  def create_episode(attrs \\ %{}) do
    %Episode{}
    |> Episode.changeset(attrs)
    |> Repo.insert()
  end

  def delete_episode(%Episode{} = episode) do
    Repo.delete(episode)
  end

  def change_episode(%Episode{} = episode, attrs \\ %{}) do
    Episode.changeset(episode, attrs)
  end

  defp query_by_user_id_and_tvshow_id(user_id, tvshow_id) do
    from ep in Episode,
      where: ep.tvshow_id == ^tvshow_id,
      join: watched_eps in "users_episodes",
      on: watched_eps.user_id == ^Ecto.UUID.dump!(user_id)
  end
end
