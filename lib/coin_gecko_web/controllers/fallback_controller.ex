defmodule CoinGeckoWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CoinGeckoWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_subscribe}) do
    conn
    |> put_status(:bad_request)
    |> put_view(CoinGeckoWeb.ErrorView)
    |> render(:"400")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(CoinGeckoWeb.ErrorView)
    |> render(:"401")
  end
end
