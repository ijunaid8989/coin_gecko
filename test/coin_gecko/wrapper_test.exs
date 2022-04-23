defmodule CoinGecko.API.WrapperTest do
  use CoinGeckoWeb.ConnCase

  setup do
    [
      bot: Application.get_env(:coin_gecko, :api_wrapper)
    ]
  end

  describe "Wrapper" do
    test "search/2 by name", %{bot: bot} do
      {:ok, response} = bot.search("Magic", "NAME")

      assert true == is_list(response)
    end

    test "search/2 by ID", %{bot: bot} do
      {:ok, response} = bot.search("fox-trading-token", "ID")

      assert true == is_map(response)

      assert "fox-trading-token" == response["id"]
    end

    test "search/2 when no coin found for ID", %{bot: bot} do
      resp = bot.search("fox", "ID")

      assert {:error, :not_found} == resp
    end

    test "search/2 when no coin found for NAME", %{bot: bot} do
      resp = bot.search("fox", "NAME")

      assert {:error, :not_found} == resp
    end

    test "market_chart/1", %{bot: bot} do
      {:ok, resp} = bot.market_chart("fox-trading-token")

      [timestamp, float] = List.first(resp)

      assert {:ok, datetime} = DateTime.from_unix(timestamp)

      assert true == is_map(datetime)

      assert true == is_float(float)
    end

    test "market_chart/1 when no coin found", %{bot: bot} do
      assert {:error, :not_found} == bot.market_chart("fox")
    end
  end
end
