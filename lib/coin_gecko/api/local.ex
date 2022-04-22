defmodule CoinGecko.API.Local do
  def search(text, by) do
    case by do
      "NAME" -> {:ok, [coin()]}
      "ID" -> {:ok, coin(text)}
    end
  end

  def market_chart(_coin_id) do
    [[6_675_515, 0.3242424]]
  end

  defp coin(id \\ "magic-token") do
    %{
      "id" => id,
      "large" => "https://assets.coingecko.com/coins/test.png",
      "market_cap_rank" => nil,
      "name" => "Magic Token",
      "symbol" => "MTK",
      "thumb" => "https://assets.coingecko.com/coins/images/test.png"
    }
  end
end
