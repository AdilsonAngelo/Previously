defmodule Previously.IMDb.IMDbHelper do
  @base_url "http://omdbapi.com/"
  @api_key System.get_env("OMDB_API_KEY")


  def search(%{"s" => _} = params) do
    params
    |> Map.put("type", "series")
    |> build_url()
    |> HTTPoison.get!()
    |> parse_response()
  end

  def get_episodes(imdb_id, season \\ 1) do
    %{i: imdb_id, season: season}
    |> build_url()
    |> HTTPoison.get!()
    |> parse_response
  end

  defp build_url(%{} = query_params) do
    query_params = Map.put(query_params, "apikey", @api_key)

    @base_url
    |> URI.parse
    |> Map.put(:query, URI.encode_query(query_params))
    |> URI.to_string()
  end

  defp parse_response(%{body: body}), do: Jason.decode!(body)
end
