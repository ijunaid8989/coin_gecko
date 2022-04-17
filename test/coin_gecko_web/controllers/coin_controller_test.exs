defmodule CoinGeckoWeb.CoinControllerTest do
  use CoinGeckoWeb.ConnCase

  setup do
    [
      url: "/api/coins",
      challenge: 123,
      mode: "subscribe",
      verify_token: Application.get_env(:coin_gecko, :webhook_token)
    ]
  end

  describe "index" do
    test "Verify webhook token", %{
      url: url,
      challenge: challenge,
      mode: mode,
      verify_token: verify_token
    } do
      conn =
        build_conn()
        |> put_resp_content_type("application/json")
        |> get(url, %{
          "hub.challenge" => challenge,
          "hub.mode" => mode,
          "hub.verify_token" => verify_token
        })

      assert challenge == json_response(conn, 200)
    end

    test "return bad request when mode is not subscribe", %{
      url: url,
      challenge: challenge,
      verify_token: verify_token
    } do
      conn =
        build_conn()
        |> put_resp_content_type("application/json")
        |> get(url, %{
          "hub.challenge" => challenge,
          "hub.mode" => "unsub",
          "hub.verify_token" => verify_token
        })

      resp = json_response(conn, 400)

      assert %{"detail" => "Wrong request parameters."} == resp["errors"]
    end

    test "return unauthorized when verify_token is not correct", %{
      url: url,
      challenge: challenge,
      mode: mode
    } do
      conn =
        build_conn()
        |> put_resp_content_type("application/json")
        |> get(url, %{
          "hub.challenge" => challenge,
          "hub.mode" => mode,
          "hub.verify_token" => "fake"
        })

      resp = json_response(conn, 401)

      assert %{"detail" => "Verify token is not correct."} == resp["errors"]
    end
  end
end
