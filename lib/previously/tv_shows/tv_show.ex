defmodule Previously.TVShows.TVShow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Previously.Episodes.Episode

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tvshows" do
    field :imdb_id, :string
    field :poster, :string
    field :title, :string
    has_many :episodes, Episode, foreign_key: :tvshow_id

    timestamps()
  end

  @doc false
  def changeset(tv_show, attrs) do
    tv_show
    |> cast(attrs, [:poster, :title, :imdb_id])
    |> validate_required([:title, :imdb_id])
    |> unique_constraint(:imdb_id)
  end
end
