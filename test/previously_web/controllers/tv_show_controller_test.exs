defmodule PreviouslyWeb.TVShowControllerTest do
  use PreviouslyWeb.ConnCase

  alias Previously.TVShows
  alias Previously.Episodes
  alias Previously.IMDb.IMDbService

  import Mock

  @user %{
    email: "test@test.com",
    password: "12345678",
    password_confirmation: "12345678"
  }

  @attrs %{
    imdb_id: "tt0475784",
    poster: "https://poster.com/poster.jpg",
    title: "Westworld"
  }

  @episode_attrs %{
    imdb_id: "tt6243308",
    title: "Kiksuya",
    release: "2018-06-10",
    number: 8,
    season: 2
  }

  @results %{
    "results" => [
      %{
        "Title" => "Westworld",
        "Year" => "2016–",
        "imdbID" => "tt0475784",
        "Type" => "series",
        "Poster" => "https://poster.com/poster.jpg"
      },
      %{
        "Title" => "Westworld",
        "Year" => "1973",
        "imdbID" => "tt0070909",
        "Type" => "movie",
        "Poster" => "https://poster.com/poster.jpg"
      }
    ],
    "total" => 2,
    "page" => 1
  }

  def mocks do
    [
      {IMDbService, [],
       [
         fetch_tvshow: fn _ -> {:ok, @attrs} end,
         fetch_episode: fn _ -> {:ok, @episode_attrs, "tt0475784"} end,
         search: fn _, _ -> {:ok, @results} end
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

  describe "index when user has watched a show" do
    test "should return watched shows", %{conn: conn} do
      with_mocks mocks() do
        assert nil == Episodes.get_by_imdb_id("tt6243308")

        post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: "tt6243308")

        conn = get(conn, Routes.api_tv_show_path(conn, :index))

        assert [
                 %{
                   "imdb_id" => "tt0475784",
                   "poster" => "https://poster.com/poster.jpg",
                   "title" => "Westworld"
                 }
               ] = json_response(conn, 200)

        assert_called(IMDbService.fetch_tvshow("tt0475784"))
        assert_called(IMDbService.fetch_episode("tt6243308"))
      end
    end
  end

  describe "show when user has watched a show" do
    test "should show", %{conn: conn} do
      with_mocks mocks() do
        {:ok, tvshow} = fixture(:tvshow)

        assert nil == Episodes.get_by_imdb_id("tt6243308")

        post(conn, Routes.api_episode_path(conn, :mark_episode), episode_code: "tt6243308")

        conn = get(conn, Routes.api_tv_show_path(conn, :show, tvshow))

        assert %{
                 "imdb_id" => "tt0475784",
                 "poster" => "https://poster.com/poster.jpg",
                 "title" => "Westworld"
               } = json_response(conn, 200)

        assert_called(IMDbService.fetch_episode("tt6243308"))
      end
    end
  end

  describe "search" do
    test "should return results from IMDb", %{conn: conn} do
      with_mocks mocks() do
        conn = get(conn, Routes.api_tv_show_path(conn, :search_imdb), q: "westworld")

        assert json_response(conn, 200) == @results

        assert_called(IMDbService.search("westworld", nil))
      end
    end
  end

  defp fixture(:episode), do: Episodes.create_episode(@episode_attrs)
end
