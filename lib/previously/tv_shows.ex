defmodule Previously.TVShows do
  @moduledoc """
  The TVShows context.
  """

  import Ecto.Query, warn: false
  alias Previously.Repo

  alias Previously.TVShows.TVShow

  @doc """
  Returns the list of tvshows.

  ## Examples

      iex> list_tvshows()
      [%TVShow{}, ...]

  """
  def list_tvshows do
    Repo.all(TVShow)
  end

  @doc """
  Gets a single tv_show.

  Raises `Ecto.NoResultsError` if the Tv show does not exist.

  ## Examples

      iex> get_tv_show!(123)
      %TVShow{}

      iex> get_tv_show!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tv_show!(id), do: Repo.get!(TVShow, id)

  @doc """
  Creates a tv_show.

  ## Examples

      iex> create_tv_show(%{field: value})
      {:ok, %TVShow{}}

      iex> create_tv_show(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tv_show(attrs \\ %{}) do
    %TVShow{}
    |> TVShow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tv_show.

  ## Examples

      iex> update_tv_show(tv_show, %{field: new_value})
      {:ok, %TVShow{}}

      iex> update_tv_show(tv_show, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tv_show(%TVShow{} = tv_show, attrs) do
    tv_show
    |> TVShow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tv_show.

  ## Examples

      iex> delete_tv_show(tv_show)
      {:ok, %TVShow{}}

      iex> delete_tv_show(tv_show)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tv_show(%TVShow{} = tv_show) do
    Repo.delete(tv_show)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tv_show changes.

  ## Examples

      iex> change_tv_show(tv_show)
      %Ecto.Changeset{data: %TVShow{}}

  """
  def change_tv_show(%TVShow{} = tv_show, attrs \\ %{}) do
    TVShow.changeset(tv_show, attrs)
  end
end
