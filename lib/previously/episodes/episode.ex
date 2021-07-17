defmodule Previously.Episodes.Episode do
  use Ecto.Schema
  import Ecto.Changeset
  alias Previously.TVShows.TVShow
  alias Previously.Users.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "episodes" do
    field :imdb_id, :string
    field :season, :integer
    field :number, :integer
    field :release, :date
    field :title, :string
    field :watched, :boolean
    belongs_to :tvshow, TVShow, foreign_key: :tvshow_id
    many_to_many :users, User, join_through: "users_episodes"

    timestamps()
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:number, :release, :title, :imdb_id, :season, :watched, :tvshow_id])
    |> cast_assoc(:tvshow)
    |> validate_required([:number, :season, :title, :imdb_id])
    |> unique_constraint(:imdb_id)
  end
end
