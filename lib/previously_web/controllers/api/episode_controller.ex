defmodule PreviouslyWeb.API.EpisodeController do
  use PreviouslyWeb, :controller
  require Logger

  alias Previously.Episodes

  action_fallback PreviouslyWeb.FallbackController

  def index(conn, %{"tv_show_id" => tvshow_id}) do
    episodes =
      conn.assigns[:current_user].id
      |> Episodes.list_episodes(tvshow_id)

    case episodes do
      [] ->
        send_resp(conn, :not_found, "")
      _ ->
        render(conn, "index.json", Jason.encode!(%{episodes: episodes, tvshow: tvshow_id}))
    end
  end

  def show(conn, %{"tv_show_id" => tvshow_id, "id" => id}) do
    episode =
      conn.assigns[:current_user].id
      |> Episodes.get_episode!(tvshow_id, id)

    render(conn, "show.json",Jason.encode!(%{episode: episode, tvshow: tvshow_id}))
  end
end
