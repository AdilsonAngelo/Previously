defmodule PreviouslyWeb.EpisodeView do
  use PreviouslyWeb, :view
  alias PreviouslyWeb.EpisodeView

  def render("index.json", %{episodes: episodes}) do
    %{data: render_many(episodes, EpisodeView, "episode.json")}
  end

  def render("show.json", %{episode: episode}) do
    %{data: render_one(episode, EpisodeView, "episode.json")}
  end

  def render("episode.json", %{episode: episode}) do
    %{season: episode.season,
      number: episode.number,
      watched: episode.watched,
      release: episode.release,
      title: episode.title,
      tvshow: episode.tvshow_id,
      imdb_id: episode.imdb_id}
  end
end
