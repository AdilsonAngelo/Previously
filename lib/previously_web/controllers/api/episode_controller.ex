defmodule PreviouslyWeb.API.EpisodeController do
  use PreviouslyWeb, :controller
  require Logger

  alias Previously.Episodes

  action_fallback PreviouslyWeb.FallbackController

  def index(conn, %{"tv_show_id" => tvshow_id}) do
    episodes = Episodes.list_episodes(tvshow_id)
    render(conn, "index.json", %{episodes: episodes, tvshow: tvshow_id})
  end

  def show(conn, %{"tv_show_id" => tvshow_id, "id" => id}) do
    episode = Episodes.get_episode!(tvshow_id, id)
    render(conn, "show.json", %{episode: episode, tvshow: tvshow_id})
  end
end
