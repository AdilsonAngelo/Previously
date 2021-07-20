defmodule Previously.TVShows do
  @moduledoc """
  The TVShows context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Adapters.SQL
  alias Previously.Repo

  alias Previously.TVShows.TVShow
  alias Previously.IMDb.IMDbService

  def list_tvshows(user_id) do
    query_by_user(user_id)
  end

  def get_tv_show!(user_id, id) do
    user_id
    |> query_by_user()
    |> Repo.get!(id)
  end

  def create_tv_show(attrs \\ %{}) do
    %TVShow{}
    |> TVShow.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_imdb_id(imdb_id), do: Repo.get_by(TVShow, imdb_id: imdb_id)
  def get_by_imdb_id!(imdb_id), do: Repo.get_by(TVShow, imdb_id: imdb_id)

  def fetch_and_save(imdb_id) do
    case IMDbService.fetch_tvshow(imdb_id) do
      {:ok, tvshow_attrs} ->
        {:ok, tvshow} = create_tv_show(tvshow_attrs)
        tvshow

      {:error, _} ->
        nil
    end
  end

  defp query_by_user(user_id) do
    result = SQL.query!(Repo, "SELECT DISTINCT tvshow.* FROM tvshows tvshow
            INNER JOIN episodes ON episodes.tvshow_id = tvshow.id
            INNER JOIN users_episodes ON users_episodes.episode_id = episodes.id
            WHERE users_episodes.user_id = $1", [Ecto.UUID.dump!(user_id)])

    result.rows
    |> Enum.map(fn row ->
      result.columns
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
    |> Enum.map(fn m -> Repo.load(TVShow, m) end)
  end
end
