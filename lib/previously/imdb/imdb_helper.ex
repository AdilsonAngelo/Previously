defmodule Previously.IMDb.IMDbHelper do
  @base_url "http://omdbapi.com/"
  @api_key Application.get_env(:omdb, :api_key)

  def search(%{"s" => _} = params) do
    params
    |> Map.put("type", "series")
    |> build_url()
    |> HTTPoison.get()
    |> parse_response()
  end

  def fetch_episode(ep_code) do
    %{i: ep_code, type: "episode"}
    |> build_url()
    |> HTTPoison.get()
    |> parse_response()
  end

  def fetch_tvshow(tvshow_code) do
    %{i: tvshow_code, type: "series"}
    |> build_url()
    |> HTTPoison.get()
    |> parse_response()
  end

  def get_episodes(imdb_id, season \\ 1) do
    %{i: imdb_id, season: season}
    |> build_url()
    |> HTTPoison.get()
    |> parse_response()
  end

  def imdb_string_to_date(date_string) do
    regex_imdb = ~r/^(?<d>\d{2}) (?<m>\w+) (?<y>\d{4})$/

    with %{"y" => year, "m" => month, "d" => day} <- Regex.named_captures(regex_imdb, date_string) do
      Date.from_iso8601!("#{year}-#{month_map()[month]}-#{day}")
    end
  end

  defp build_url(%{} = query_params) do
    query_params = Map.put(query_params, "apikey", @api_key)

    @base_url
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(query_params))
    |> URI.to_string()
  end

  defp parse_response({_, %{body: body}}) do
    case Jason.decode(body) do
      {:ok, result} -> result
      {:error, _} -> nil
    end
  end

  defp month_map do
    ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    |> Enum.zip(1..12)
    |> Enum.map(fn {k, v} ->
      {k, String.pad_leading("#{v}", 2, "0")}
    end)
    |> Enum.into(%{})
  end
end
