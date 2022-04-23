defmodule CoinGecko.API.Local do
  def search(text, by) do
    case by do
      "NAME" -> by_name(text)
      "ID" -> by_id(text)
    end
  end

  def market_chart(coin_id) do
    coins()
    |> Enum.filter(&(&1["id"] == coin_id))
    |> case do
      [] -> {:error, :not_found}
      _list -> {:ok, [[DateTime.utc_now() |> DateTime.to_unix(), 0.3242424]]}
    end
  end

  defp by_name(name) do
    coins()
    |> Enum.filter(&String.contains?(&1["name"], name))
    |> case do
      [] -> {:error, :not_found}
      list -> {:ok, list}
    end
  end

  defp by_id(id) do
    coins()
    |> Enum.filter(&(&1["id"] == id))
    |> case do
      [] -> {:error, :not_found}
      list -> {:ok, List.first(list)}
    end
  end

  defp coins() do
    [
      %{
        "id" => "cts-coin",
        "large" => "https://assets.coingecko.com/coins/images/7476/large/cstc.png",
        "market_cap_rank" => 3626,
        "name" => "Crypto Trading Solutions Coin",
        "symbol" => "CTSC",
        "thumb" => "https://assets.coingecko.com/coins/images/7476/thumb/cstc.png"
      },
      %{
        "id" => "decentralized-asset-trading-platform",
        "large" =>
          "https://assets.coingecko.com/coins/images/6565/large/Decentralized_Asset_Trading_Platform.jpg",
        "market_cap_rank" => 3650,
        "name" => "Decentralized Asset Trading Platform",
        "symbol" => "DATP",
        "thumb" =>
          "https://assets.coingecko.com/coins/images/6565/thumb/Decentralized_Asset_Trading_Platform.jpg"
      },
      %{
        "id" => "fox-trading-token",
        "large" => "https://assets.coingecko.com/coins/images/5182/large/foxtrading-logo.png",
        "market_cap_rank" => nil,
        "name" => "Fox Trading Token",
        "symbol" => "FOXT",
        "thumb" => "https://assets.coingecko.com/coins/images/5182/thumb/foxtrading-logo.png"
      },
      %{
        "id" => "alliance-x-trading",
        "large" =>
          "https://assets.coingecko.com/coins/images/11124/large/a02f067fc027d99c4f1b1d36ad98205c.png",
        "market_cap_rank" => nil,
        "name" => "Alliance X Trading",
        "symbol" => "AXT",
        "thumb" =>
          "https://assets.coingecko.com/coins/images/11124/thumb/a02f067fc027d99c4f1b1d36ad98205c.png"
      },
      %{
        "id" => "magic-trading-token",
        "large" => "https://assets.coingecko.com/coins/images/19961/large/MTK_Low.png",
        "market_cap_rank" => nil,
        "name" => "Magic Trading Token",
        "symbol" => "MTK",
        "thumb" => "https://assets.coingecko.com/coins/images/19961/thumb/MTK_Low.png"
      }
    ]
  end
end
