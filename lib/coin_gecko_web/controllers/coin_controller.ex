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
