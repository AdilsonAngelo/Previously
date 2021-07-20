defmodule Previously.IMDb.IMDbService do
  alias Previously.IMDb.IMDbHelper

  def search(query, page \\ 1) do
    case IMDbHelper.search(%{"s" => query, "page" => page}) do
      %{"Search" => results, "Response" => "True", "totalResults" => total} ->
        total_num = String.to_integer(total)
        page = if page === nil, do: 1, else: String.to_integer(page)

        results =
          results
          |> Enum.map(fn res ->
            res
            |> Enum.map(fn {k, v} ->
              k = if (String.downcase(k) == "imdbid"), do: "imdb_id", else: k
              {String.downcase(k), v}
            end)
            |> Enum.into(%{})
          end)

        {:ok, %{"results" => results, "total" => total_num, "page" => page}}

      %{"Error" => err, "Response" => "False"} ->
        {:error, err}
    end
  end

  def fetch_episode(ep_code) do
    case IMDbHelper.fetch_episode(ep_code) do
      %{
        "Title" => title,
        "Released" => release_date,
        "Season" => season,
        "Episode" => number,
        "seriesID" => tvshow_imdb_id,
        "imdbID" => ^ep_code,
        "Type" => "episode"
      } ->
        episode = %{
          imdb_id: ep_code,
          season: String.to_integer(season),
          number: String.to_integer(number),
          release: IMDbHelper.imdb_string_to_date(release_date),
          title: title
        }

        {:ok, episode, tvshow_imdb_id}

      _ ->
        {:error, nil, nil}
    end
  end

  def fetch_tvshow(tvshow_code) do
    case IMDbHelper.fetch_tvshow(tvshow_code) do
      %{
        "Title" => title,
        "Poster" => poster,
        "imdbID" => ^tvshow_code
      } ->
        tvshow = %{
          imdb_id: tvshow_code,
          poster: poster,
          title: title
        }

        {:ok, tvshow}

      _ ->
        {:error, nil}
    end
  end

  def get_episodes(tvshow_code, season \\ 1) do
    case IMDbHelper.get_episodes(tvshow_code, season) do
      %{
        "Title" => title,
        "Season" => season,
        "totalSeasons" => total_seasons,
        "Episodes" => episodes
      } ->
        tvshow_episodes = %{
          title: title,
          season: season,
          total_seasons: total_seasons,
          episodes: episodes
        }

        {:ok, tvshow_episodes}

      res ->
        {:error, res}
    end
  end
end
