defmodule PreviouslyWeb.API.TVShowController do
  use PreviouslyWeb, :controller

  alias Previously.TVShows
  alias Previously.IMDb.IMDbService

  action_fallback PreviouslyWeb.FallbackController

  def index(conn, _params) do
    tvshows = TVShows.list_tvshows()
    render(conn, "index.json", tvshows: tvshows)
  end

  def show(conn, %{"id" => id}) do
    tv_show = TVShows.get_tv_show!(id)
    render(conn, "show.json", tv_show: tv_show)
  end

  def search_imdb(conn, %{"q" => query} = params) do
    case IMDbService.search(query, params["page"]) do
      {:ok, response} ->
        send_resp(conn, :ok, Jason.encode!(response))
      {:error, err} ->
        send_resp(conn, 500, Jason.encode!(%{"error" => err}))
    end
  end
end
