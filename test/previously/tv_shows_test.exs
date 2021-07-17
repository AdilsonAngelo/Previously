defmodule Previously.TVShowsTest do
  use Previously.DataCase

  alias Previously.TVShows

  describe "tvshows" do
    alias Previously.TVShows.TVShow

    @valid_attrs %{imdb_id: "some imdb_id", poster: "some poster", title: "some title"}
    @update_attrs %{imdb_id: "some updated imdb_id", poster: "some updated poster", title: "some updated title"}
    @invalid_attrs %{imdb_id: nil, poster: nil, title: nil}

    def tv_show_fixture(attrs \\ %{}) do
      {:ok, tv_show} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TVShows.create_tv_show()

      tv_show
    end

    test "list_tvshows/0 returns all tvshows" do
      tv_show = tv_show_fixture()
      assert TVShows.list_tvshows() == [tv_show]
    end

    test "get_tv_show!/1 returns the tv_show with given id" do
      tv_show = tv_show_fixture()
      assert TVShows.get_tv_show!(tv_show.id) == tv_show
    end

    test "create_tv_show/1 with valid data creates a tv_show" do
      assert {:ok, %TVShow{} = tv_show} = TVShows.create_tv_show(@valid_attrs)
      assert tv_show.imdb_id == "some imdb_id"
      assert tv_show.poster == "some poster"
      assert tv_show.title == "some title"
    end

    test "create_tv_show/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TVShows.create_tv_show(@invalid_attrs)
    end

    test "update_tv_show/2 with valid data updates the tv_show" do
      tv_show = tv_show_fixture()
      assert {:ok, %TVShow{} = tv_show} = TVShows.update_tv_show(tv_show, @update_attrs)
      assert tv_show.imdb_id == "some updated imdb_id"
      assert tv_show.poster == "some updated poster"
      assert tv_show.title == "some updated title"
    end

    test "update_tv_show/2 with invalid data returns error changeset" do
      tv_show = tv_show_fixture()
      assert {:error, %Ecto.Changeset{}} = TVShows.update_tv_show(tv_show, @invalid_attrs)
      assert tv_show == TVShows.get_tv_show!(tv_show.id)
    end

    test "delete_tv_show/1 deletes the tv_show" do
      tv_show = tv_show_fixture()
      assert {:ok, %TVShow{}} = TVShows.delete_tv_show(tv_show)
      assert_raise Ecto.NoResultsError, fn -> TVShows.get_tv_show!(tv_show.id) end
    end

    test "change_tv_show/1 returns a tv_show changeset" do
      tv_show = tv_show_fixture()
      assert %Ecto.Changeset{} = TVShows.change_tv_show(tv_show)
    end
  end
end
