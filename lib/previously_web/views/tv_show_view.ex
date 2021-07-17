defmodule PreviouslyWeb.TVShowView do
  use PreviouslyWeb, :view
  alias PreviouslyWeb.TVShowView

  def render("index.json", %{tvshows: tvshows}) do
    %{data: render_many(tvshows, TVShowView, "tv_show.json")}
  end

  def render("show.json", %{tv_show: tv_show}) do
    %{data: render_one(tv_show, TVShowView, "tv_show.json")}
  end

  def render("tv_show.json", %{tv_show: tv_show}) do
    %{poster: tv_show.poster,
      title: tv_show.title,
      imdb_id: tv_show.imdb_id}
  end
end
