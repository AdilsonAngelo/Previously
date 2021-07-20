defmodule PreviouslyWeb.API.TVShowController do
  use PreviouslyWeb, :controller

  alias Previously.TVShows
  alias Previously.IMDb.IMDbService

  action_fallback PreviouslyWeb.FallbackController

  def index(conn, _params) do
    tvshows =
      conn
      |> get_user_id()
      |> TVShows.list_tvshows()

    render(conn, "index.json", tvshows: tvshows)
  end

  def show(conn, %{"id" => id}) do
    tvshow =
      conn
      |> get_user_id()
      |> TVShows.get_tv_show!(id)

    render(conn, "show.json", tv_show: tvshow)
  end

  def search_imdb(conn, %{"q" => query} = params) do
    case IMDbService.search(query, params["page"]) do
      {:ok, response} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:ok, Jason.encode!(response))

      {:error, "Series not found!"} ->
        send_resp(conn, 404, '')

      {:error, err} ->
        send_resp(conn, 500, Jason.encode!(%{"error" => err}))
    end
  end

  def get_tvshow_episodes(conn, %{"tvshow_code" => tvshow_code, "season" => season}) do
    case IMDbService.get_episodes(tvshow_code, season) do
      {:ok, tvshow_episodes} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:ok, Jason.encode!(tvshow_episodes))

      {:error, err} ->
        send_resp(conn, 500, Jason.encode!(%{"error" => err}))
    end
  end

  defp get_user_id(conn), do: conn.assigns[:current_user].id
end
