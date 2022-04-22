defmodule CoinGecko.API.Wrapper do
  @type coin :: %{
          id: String.t(),
          large: String.t(),
          name: String.t(),
          symbol: String.t(),
          thumb: String.t()
        }
  @spec search(text :: String.t(), by :: String.t()) ::
          {:ok, coin()} | {:ok, [coin()]} | {:error, :not_found}
  def search(text, by) do
    case by do
      "NAME" -> by_name(text)
      "ID" -> by_id(text)
    end
  end

  @type chart :: [unix_timestamp: integer, usd: integer]
  @spec market_chart(coin_id :: String.t()) :: [chart] | {:error, :not_found}
  def market_chart(coin_id) do
    (coingecko_api() <> "/coins/" <> coin_id <> "/market_chart?vs_currency=usd&days=14")
    |> get()
    |> case do
      {:ok, coins} -> {:ok, coins["prices"]}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp by_id(id) do
    (coingecko_api() <> "/coins/" <> id)
    |> get()
  end

  defp by_name(name) do
    (coingecko_api() <> "/search?query=" <> name)
    |> get()
    |> case do
      {:ok, coins} -> {:ok, Enum.take(coins["coins"], 5)}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp get(url) do
    headers = [{"Content-type", "application/json"}]

    HTTPoison.get(url, headers)
    |> process_response_body()
  end

  defp process_response_body({:ok, %HTTPoison.Response{body: body, status_code: 200}}),
    do: Jason.decode(body)

  defp process_response_body(_response), do: {:error, :not_found}

  defp coingecko_api(), do: "https://api.coingecko.com/api/v3"
end
