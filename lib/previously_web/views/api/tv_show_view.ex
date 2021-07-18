defmodule PreviouslyWeb.API.TVShowView do
  use PreviouslyWeb, :view
  alias PreviouslyWeb.API.TVShowView

  def render("index.json", %{tvshows: tvshows}) do
    render_many(tvshows, TVShowView, "tv_show.json")
  end

  def render("show.json", %{tv_show: tv_show}) do
    render_one(tv_show, TVShowView, "tv_show.json")
  end

  def render("tv_show.json", %{tv_show: tv_show}) do
    %{poster: tv_show.poster,
      title: tv_show.title,
      imdb_id: tv_show.imdb_id}
  end
end
