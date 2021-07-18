defmodule Previously.Episodes do
  @moduledoc """
  The Episodes context.
  """

  require Ecto.UUID
  import Ecto.Query, warn: false
  alias Previously.Repo

  alias Previously.Episodes.Episode

  @doc """
  Returns the list of episodes.

  ## Examples

      iex> list_episodes()
      [%Episode{}, ...]

  """
  def list_episodes(user_id, tvshow_id) do
    user_id
    |> query_by_user_id_and_tvshow_id(tvshow_id)
    |> Repo.all()
  end

  @doc """
  Gets a single episode.

  Raises `Ecto.NoResultsError` if the Episode does not exist.

  ## Examples

      iex> get_episode!(123)
      %Episode{}

      iex> get_episode!(456)
      ** (Ecto.NoResultsError)

  """
  def get_episode!(user_id, tvshow_id, id) do
    user_id
    |> query_by_user_id_and_tvshow_id(tvshow_id)
    |> Repo.get!(id)
  end

  @doc """
  Creates a episode.

  ## Examples

      iex> create_episode(%{field: value})
      {:ok, %Episode{}}

      iex> create_episode(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_episode(attrs \\ %{}) do
    %Episode{}
    |> Episode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a episode.

  ## Examples

      iex> update_episode(episode, %{field: new_value})
      {:ok, %Episode{}}

      iex> update_episode(episode, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_episode(%Episode{} = episode, attrs) do
    episode
    |> Episode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a episode.

  ## Examples

      iex> delete_episode(episode)
      {:ok, %Episode{}}

      iex> delete_episode(episode)
      {:error, %Ecto.Changeset{}}

  """
  def delete_episode(%Episode{} = episode) do
    Repo.delete(episode)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking episode changes.

  ## Examples

      iex> change_episode(episode)
      %Ecto.Changeset{data: %Episode{}}

  """
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
