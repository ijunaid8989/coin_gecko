defmodule CoinGecko.Bot.Messaging do
  def set_get_started_with_greetings() do
    body =
      Jason.encode!(%{
        "get_started" => %{
          "payload" => "GET_STARTED_PAYLOAD"
        },
        "greeting" => [
          %{
            "locale" => "default",
            "text" => "Hello {{user_first_name}}! how are you doing today?"
          },
        ]
      })

    headers = [{"Content-type", "application/json"}]

    (messenger_profile_api() <> "?access_token=" <> access_token())
    |> HTTPoison.post(body, headers, [])
    |> IO.inspect()
  end

  defp messenger_profile_api(), do: Application.get_env(:coin_gecko, :messenger_profile_api)
  defp messages_api(), do: Application.get_env(:coin_gecko, :messages)
  defp access_token(), do: Application.get_env(:coin_gecko, :webhook_token)
  defp graph_api(), do: Application.get_env(:coin_gecko, :graph)
end
