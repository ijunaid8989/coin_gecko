defmodule CoinGeckoWeb.CoinController do
  use CoinGeckoWeb, :controller

  action_fallback CoinGeckoWeb.FallbackController

  alias CoinGecko.Flow.Handler

  @spec index(any, map) :: {:error, :not_subscribe | :unauthorized} | Plug.Conn.t()
  def index(
        conn,
        %{"hub.challenge" => challenge, "hub.mode" => mode, "hub.verify_token" => verify_token} =
          _params
      ) do
    with {:ok, _mode} <- mode(mode),
         {:ok, _token} <- verify_token(verify_token) do
      send_resp(conn, :ok, challenge)
    end
  end

  def create(
        conn,
        %{
          "entry" => [
            %{
              "messaging" => [messaging]
            }
          ]
        } = _params
      ) do
    case messaging do
      %{
        "postback" => %{
          "payload" => "GET_STARTED_PAYLOAD"
        },
        "sender" => %{"id" => recipient_id}
      } ->
        Handler.init(recipient_id)

      %{
        "postback" => %{
          "payload" => payload
        },
        "sender" => %{"id" => recipient_id}
      }
      when payload in ["NAME", "ID"] ->
        Handler.search_payload(recipient_id, payload)

      %{
        "message" => %{
          "nlp" => _nlp,
          "quick_reply" => %{"payload" => coin_id}
        },
        "sender" => %{"id" => recipient_id}
      } ->
        Handler.send_coins_listings(recipient_id, coin_id)

      %{
        "message" => %{
          "nlp" => _nlp,
          "text" => text
        },
        "sender" => %{"id" => recipient_id}
      } ->
        Handler.random_reply(recipient_id, text)

      _ ->
        :ok
    end

    send_resp(conn, :ok, "")
  end

  defp webhook_verify_token(), do: Application.get_env(:coin_gecko, :webhook_token)

  defp mode("subscribe" = mode), do: {:ok, mode}
  defp mode(_), do: {:error, :not_subscribe}

  defp verify_token(token) do
    case token == webhook_verify_token() do
      true -> {:ok, token}
      false -> {:error, :unauthorized}
    end
  end
end
