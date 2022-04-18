defmodule CoinGeckoWeb.CoinController do
  use CoinGeckoWeb, :controller

  action_fallback CoinGeckoWeb.FallbackController

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
    IO.inspect(messaging)

    case messaging do
      %{
        "postback" => %{
          "payload" => "GET_STARTED_PAYLOAD"
        },
        "sender" => %{"id" => recipient_id}
      } ->
        bot().set_mark_seen(recipient_id)
        bot().post_coins_question(recipient_id)

      %{
        "message" => %{
          "nlp" => _nlp,
          "text" => _text
        },
        "sender" => %{"id" => recipient_id}
      } ->
        bot().set_mark_seen(recipient_id)
        bot().post_random_reply(recipient_id, "hmm, Please choose wisely from the above options.")

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

  defp bot(), do: Application.get_env(:coin_gecko, :bot_messaging)
end
