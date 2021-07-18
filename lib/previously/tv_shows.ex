defmodule Previously.TVShows do
  @moduledoc """
  The TVShows context.
  """

  import Ecto.Query, warn: false
  alias Previously.Repo

  alias Previously.TVShows.TVShow
  alias Previously.Episodes.Episode
  alias Previously.IMDb.IMDbService

  def list_tvshows(user_id) do
    user_id
    |> query_by_user_id()
    |> Repo.all()
  end

  def get_tv_show!(user_id, id) do
    user_id
    |> query_by_user_id()
    |> Repo.get!(id)
  end

  def create_tv_show(attrs \\ %{}) do
    %TVShow{}
    |> TVShow.changeset(attrs)
    |> Repo.insert()
  end

  def update_tv_show(%TVShow{} = tv_show, attrs) do
    tv_show
    |> TVShow.changeset(attrs)
    |> Repo.update()
  end

  def delete_tv_show(%TVShow{} = tv_show) do
    Repo.delete(tv_show)
  end

  def change_tv_show(%TVShow{} = tv_show, attrs \\ %{}) do
    TVShow.changeset(tv_show, attrs)
  end

  def get_by_imdb_id(imdb_id), do: Repo.get_by(TVShow, imdb_id: imdb_id)

  def fetch_and_save(imdb_id) do
    case IMDbService.fetch_tvshow(imdb_id) do
      {:ok, tvshow_attrs} ->
        {:ok, tvshow} = create_tv_show(tvshow_attrs)
        tvshow

      {:error, _} ->
        nil
    end
  end

  defp query_by_user_id(user_id) do
    from tvshow in TVShow,
      join: ep in Episode,
      on: ep.tvshow_id == tvshow.id,
      join: watched_eps in "users_episodes",
      on: watched_eps.user_id == ^Ecto.UUID.dump!(user_id)
  end
end
