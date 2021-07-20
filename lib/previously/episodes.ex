defmodule Previously.Episodes do
  @moduledoc """
  The Episodes context.
  """

  require Ecto.UUID
  import Ecto.Query, warn: false
  alias Ecto.Adapters.SQL
  alias Previously.Repo

  alias Previously.Episodes.Episode
  alias Previously.TVShows
  alias Previously.TVShows.TVShow
  alias Previously.IMDb.IMDbService

  def list_episodes(user_id, tvshow_id) do
    tvshow_id
    |> query_by_tvshow_id()
    |> Repo.all()
    |> Repo.preload(:users)
    |> filter_by_user(user_id)
  end

  def get_marked_by_tvshow_code(user_id, tvshow_code) do
    case TVShows.get_by_imdb_id(tvshow_code) do
      nil ->
        []

      tvshow ->
        list_episodes(user_id, tvshow.id)
    end
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

  def unmark_all_episodes(user_id, tvshow_code) do
    marked_eps_ids =
      user_id
      |> get_marked_by_tvshow_code(tvshow_code)
      |> Enum.map(fn ep -> Ecto.UUID.dump!(ep.id) end)

    query =
      from ue in "users_episodes",
        where:
          ue.user_id == ^Ecto.UUID.dump!(user_id) and
            ue.episode_id in ^marked_eps_ids

    Repo.delete_all(query)
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

  def get_last_episodes(user_id) do
    result =
      SQL.query!(
        Repo,
        "SELECT DISTINCT MAX(ep.number) AS number, ep.season, ep.tvshow_id FROM episodes ep
        INNER JOIN
        (SELECT DISTINCT MAX(ep.season) AS season, ep.tvshow_id FROM episodes ep
        INNER JOIN users_episodes ON users_episodes.episode_id = ep.id
        WHERE users_episodes.user_id = $1
        GROUP BY ep.tvshow_id) st
        ON ep.tvshow_id = st.tvshow_id
        WHERE ep.season = st.season
        GROUP BY ep.tvshow_id, ep.season;",
        [Ecto.UUID.dump!(user_id)]
      )

    result.rows
    |> Enum.map(fn row ->
      result.columns
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
    |> Enum.map(fn r -> Map.put(r, "tvshow_id", Ecto.UUID.load!(r["tvshow_id"])) end)
    |> Enum.map(fn r ->
      Map.put(r, "tvshow_imdb_id", Repo.get!(TVShow, r["tvshow_id"]).imdb_id)
    end)
  end

  defp query_by_user_id_and_tvshow_id(user_id, tvshow_id) do
    from ep in Episode,
      where: ep.tvshow_id == ^tvshow_id,
      join: watched_eps in "users_episodes",
      on: watched_eps.user_id == ^Ecto.UUID.dump!(user_id)
  end

  defp query_by_tvshow_id(tvshow_id) do
    from ep in Episode,
      where: ep.tvshow_id == ^tvshow_id
  end

  defp filter_by_user(episodes, user_id) do
    Enum.filter(episodes, fn ep ->
      ep.users
      |> Enum.map(fn usr -> usr.id == user_id end)
      |> Enum.any?()
    end)
  end
end
