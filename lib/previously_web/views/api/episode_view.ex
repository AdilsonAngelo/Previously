defmodule PreviouslyWeb.API.EpisodeView do
  use PreviouslyWeb, :view
  alias PreviouslyWeb.API.EpisodeView

  def render("index.json", %{episodes: episodes}) do
    render_many(episodes, EpisodeView, "episode.json")
  end

  def render("show.json", %{episode: episode}) do
    render_one(episode, EpisodeView, "episode.json")
  end

  def render("episode.json", %{episode: episode}) do
    %{season: episode.season,
      number: episode.number,
      release: episode.release,
      title: episode.title}
  end
end
