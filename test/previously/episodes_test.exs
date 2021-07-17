defmodule Previously.EpisodesTest do
  use Previously.DataCase

  alias Previously.Episodes
  alias Previously.TVShows

  describe "episodes" do
    alias Previously.Episodes.Episode

    @valid_tvshow_attrs %{imdb_id: "show_imdb_id", poster: "some poster", title: "some title"}
    @valid_attrs %{imdb_id: "some imdb_id", number: 42, release: ~D[2010-04-17], title: "some title", season: 1}
    @update_attrs %{imdb_id: "some updated imdb_id", number: 43, release: ~D[2011-05-18], title: "some updated title", season: 2, watched: true}
    @invalid_attrs %{imdb_id: nil, number: nil, release: nil, title: nil}

    def tvshow_fixture() do
      {:ok, tvshow} = TVShows.create_tv_show(@valid_tvshow_attrs)
      tvshow
    end

    def episode_fixture(attrs \\ %{}) do
      tvshow = tvshow_fixture()

      {:ok, episode} =
        attrs
        |> Map.put(:tvshow_id, tvshow.id)
        |> Enum.into(@valid_attrs)
        |> Episodes.create_episode()

      {tvshow, episode}
    end

    test "list_episodes/0 returns all episodes" do
      {_, episode} = episode_fixture()
      assert Episodes.list_episodes() == [episode]
    end

    test "get_episode!/1 returns the episode with given id" do
      {_, episode} = episode_fixture()
      assert Episodes.get_episode!(episode.id) == episode
    end

    test "create_episode/1 with valid data creates a episode" do
      tvshow = tvshow_fixture()

      assert {:ok, %Episode{} = episode} =
        @valid_attrs
        |> Map.put(:tvshow_id, tvshow.id)
        |> Episodes.create_episode()

      assert episode.imdb_id == "some imdb_id"
      assert episode.number == 42
      assert episode.release == ~D[2010-04-17]
      assert episode.title == "some title"
      assert episode.season == 1
      assert episode.tvshow_id == tvshow.id
    end

    test "create_episode/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Episodes.create_episode(@invalid_attrs)
    end

    test "update_episode/2 with valid data updates the episode" do
      {tvshow, episode} = episode_fixture()
      assert {:ok, %Episode{} = episode} = Episodes.update_episode(episode, @update_attrs)
      assert episode.imdb_id == "some updated imdb_id"
      assert episode.number == 43
      assert episode.release == ~D[2011-05-18]
      assert episode.title == "some updated title"
      assert episode.season == 2
      assert episode.tvshow_id == tvshow.id
    end

    test "update_episode/2 with invalid data returns error changeset" do
      {_, episode} = episode_fixture()
      assert {:error, %Ecto.Changeset{}} = Episodes.update_episode(episode, @invalid_attrs)
      assert episode == Episodes.get_episode!(episode.id)
    end

    test "delete_episode/1 deletes the episode" do
      {_, episode} = episode_fixture()
      assert {:ok, %Episode{}} = Episodes.delete_episode(episode)
      assert_raise Ecto.NoResultsError, fn -> Episodes.get_episode!(episode.id) end
    end

    test "change_episode/1 returns a episode changeset" do
      {_, episode} = episode_fixture()
      assert %Ecto.Changeset{} = Episodes.change_episode(episode)
    end
  end
end
