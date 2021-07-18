defmodule PreviouslyWeb.EpisodeControllerTest do
  use PreviouslyWeb.ConnCase

  alias Previously.TVShows
  alias Previously.Episodes
  alias Previously.IMDb.IMDbService
  alias Previously.Repo

  import Mock

  @user %{
    email: "test@test.com",
    password: "12345678",
    password_confirmation: "12345678"
  }

  @mark_attrs "tt6243308"
  @invalid_mark_attrs 190
  @tvshow_attrs %{
    imdb_id: "tt0475784",
    poster:
      "https://m.media-amazon.com/images/M/MV5BMTRmYzNmOTctZjMwOS00ODZlLWJiZGQtNDg5NDY5NjE3MTczXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_SX300.jpg",
    title: "Westworld"
  }
  @episode_attrs %{
    imdb_id: "tt6243308",
    title: "Kiksuya",
    release: "2018-06-10",
    number: 8,
    season: 2
  }

  def mocks do
    [
      {IMDbService, [],
       [
         fetch_tvshow: fn _ -> {:ok, @tvshow_attrs} end,
         fetch_episode: fn _ -> {:ok, @episode_attrs, "tt0475784"} end
       ]}
    ]
  end

  def mocks_nonexistent do
    [
      {IMDbService, [],
       [
        fetch_episode: fn _ -> {:error, nil, nil} end,
       ]}
    ]
  end

  setup %{conn: conn} do
    assert %{
             "data" => %{
               "access_token" => access_token
             }
           } =
             conn
             |> post(Routes.api_registration_path(conn, :create), user: @user)
             |> json_response(200)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", access_token)

    {:ok, conn: conn}
  end

  describe "#mark_episode when episode code is valid" do
    test "should be successful", %{conn: conn} do
      with_mocks mocks() do
        conn = post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: @mark_attrs)

        assert response(conn, 204)

        assert_called(IMDbService.fetch_tvshow("tt0475784"))
        assert_called(IMDbService.fetch_episode("tt6243308"))
      end
    end

    test "should create user-episode relation", %{conn: conn} do
      with_mocks mocks() do
        {:ok, episode} = fixture(:episode)
        episode = load_users(episode)

        assert episode.users == []

        post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: @mark_attrs)

        episode_after =
          @mark_attrs
          |> Episodes.get_by_imdb_id!()
          |> load_users()

        assert length(episode_after.users) == 1
        assert Enum.at(episode_after.users, 0).email == @user.email
      end
    end

    test "should create episode if it doesn't exist", %{conn: conn} do
      with_mocks mocks() do
        assert nil == Episodes.get_by_imdb_id(@mark_attrs)

        post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: @mark_attrs)

        assert %{
                 imdb_id: "tt6243308",
                 title: "Kiksuya",
                 release: ~D[2018-06-10],
                 number: 8,
                 season: 2
               } = Episodes.get_by_imdb_id(@mark_attrs)
      end
    end

    test "should not fetch episode if it already exists", %{conn: conn} do
      with_mocks mocks() do
        fixture(:episode)

        assert %{
                 imdb_id: "tt6243308",
                 title: "Kiksuya",
                 release: ~D[2018-06-10],
                 number: 8,
                 season: 2
               } = Episodes.get_by_imdb_id(@mark_attrs)

        post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: @mark_attrs)

        assert_not_called(IMDbService.fetch_episode("tt6243308"))
      end
    end

    test "should not fetch tvshow if it already exists", %{conn: conn} do
      with_mocks mocks() do
        fixture(:tvshow)

        assert %{
                 imdb_id: "tt0475784",
                 poster:
                   "https://m.media-amazon.com/images/M/MV5BMTRmYzNmOTctZjMwOS00ODZlLWJiZGQtNDg5NDY5NjE3MTczXkEyXkFqcGdeQXVyMDM2NDM2MQ@@._V1_SX300.jpg",
                 title: "Westworld"
               } = TVShows.get_by_imdb_id("tt0475784")

        post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: @mark_attrs)

        assert_not_called(IMDbService.fetch_tvshow("tt0475784"))
      end
    end
  end

  describe "#mark_episode when episode code is NOT valid" do
    test "should return 400 if episode_code is not a string", %{conn: conn} do
      with_mocks mocks() do
        conn =
          post(conn, Routes.api_episode_path(conn, :mark_episode),
            episode_code: @invalid_mark_attrs
          )

        assert response(conn, 400)
      end
    end

    test "should return 404 if episode_code doesn't exist on IMDb", %{conn: conn} do
      with_mocks mocks_nonexistent() do
        conn =
          post(conn, Routes.api_episode_path(conn, :mark_episode),
            episode_code: "non_existent"
          )

        assert response(conn, 404)
      end
    end
  end

  describe "#index when tv_show_id is valid" do
    test "should return empty list when there are no marked episodes", %{conn: conn} do
      with_mocks mocks() do
        {:ok, tvshow} = fixture(:tvshow)

        conn = get(conn, Routes.api_tv_show_episode_path(conn, :index, tvshow.id))

        assert json_response(conn, 200) == []
      end
    end

    test "should return marked episodes", %{conn: conn} do
      with_mocks mocks() do
        {:ok, tvshow} = fixture(:tvshow)

        conn = post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: @mark_attrs)

        assert response(conn, 204)

        conn = get(conn, Routes.api_tv_show_episode_path(conn, :index, tvshow))

        assert [%{
            "imdb_id" => "tt6243308",
            "number" => 8,
            "release" => "2018-06-10",
            "season" => 2,
            "title" => "Kiksuya",
        }] = json_response(conn, 200)
      end
    end
  end

  defp load_users(%Episodes.Episode{} = ep), do: Repo.preload(ep, :users)

  defp fixture(:episode), do: Episodes.create_episode(@episode_attrs)
  defp fixture(:tvshow), do: TVShows.create_tv_show(@tvshow_attrs)
end
