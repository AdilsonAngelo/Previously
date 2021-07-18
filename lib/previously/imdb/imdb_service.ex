defmodule Previously.IMDb.IMDbService do
  alias Previously.IMDb.IMDbHelper

  @spec search(String.t(), Integer.t()) :: any
  def search(query, page \\ 1) do
    case IMDbHelper.search(%{"s" => query, "page" => page}) do
      %{"Search" => results, "Response" => "True", "totalResults" => total} ->
        total_num = String.to_integer(total)
        page = if page === nil, do: 1, else: page
        {:ok, %{"results" => results, "total" => total_num, "page" => page }}
      %{"Error" => err, "Response" => "False"} ->
        {:error, err}
    end
  end
end
