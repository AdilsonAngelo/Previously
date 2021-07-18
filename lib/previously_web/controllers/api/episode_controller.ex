defmodule PreviouslyWeb.API.EpisodeController do
  use PreviouslyWeb, :controller

  alias Previously.Episodes

  action_fallback PreviouslyWeb.FallbackController
  def index(conn, %{"tv_show_id" => tvshow_id}) when is_binary(tvshow_id) do
    episodes =
      conn
      |> get_user_id()
      |> Episodes.list_episodes(tvshow_id)

    render(conn, "index.json", episodes: episodes)
  end

  def show(conn, %{"tv_show_id" => tvshow_id, "id" => id}) do
    episode =
      conn
      |> get_user_id()
      |> Episodes.get_episode!(tvshow_id, id)

    render(conn, "show.json", episode: episode)
  end

  def mark_episode(conn, %{"episode_code" => ep_code}) when is_bitstring(ep_code) do
    episode =
      conn.assigns[:current_user]
      |> Episodes.mark_episode(ep_code)

    case episode do
      {:ok, _} ->
        send_resp(conn, :no_content, "")

      {:error, :not_found, message} ->
        send_resp(conn, :not_found, message)

      res ->
        res
    end
  end

  def mark_episode(conn, _),
    do:
      send_resp(
        conn,
        :bad_request,
        Jason.encode!(%{errors: %{detail: "episode_code should be string"}})
      )

  def unmark_episode(conn, %{"episode_code" => ep_code}) when is_bitstring(ep_code) do
    conn
    |> get_user_id()
    |> Episodes.unmark_episode(ep_code)

    send_resp(conn, :no_content, "")
  end

  def unmark_episode(conn, _),
    do:
      send_resp(
        conn,
        :bad_request,
        Jason.encode!(%{errors: %{detail: "episode_code should be string"}})
      )

  defp get_user_id(conn), do: conn.assigns[:current_user].id
end
