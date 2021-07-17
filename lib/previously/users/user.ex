defmodule Previously.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  alias Previously.Episodes.Episode

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    pow_user_fields()

    many_to_many :episodes, Episode, join_through: "users_episodes"

    timestamps()
  end
end
