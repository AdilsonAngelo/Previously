defmodule Previously.TVShows do
  @moduledoc """
  The TVShows context.
  """

  import Ecto.Query, warn: false
  alias Previously.Repo

  alias Previously.TVShows.TVShow
  alias Previously.IMDb.IMDbService

  def list_tvshows do
    Repo.all(TVShow)
  end

  def get_tv_show!(id), do: Repo.get!(TVShow, id)

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
end
