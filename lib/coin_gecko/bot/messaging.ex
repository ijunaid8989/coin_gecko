defmodule CoinGecko.Bot.Messaging do
  def set_get_started_with_greetings() do
    message =
      Jason.encode!(%{
        "get_started" => %{
          "payload" => "GET_STARTED_PAYLOAD"
        },
        "greeting" => [
          %{
            "locale" => "default",
            "text" => "Hello {{user_first_name}}! how are you doing today?"
          }
        ]
      })

    messenger_profile_api()
    |> post(message)
  end

  def set_mark_seen(recipient_id) do
    message =
      Jason.encode!(%{
        "recipient" => %{
          "id" => recipient_id
        },
        "sender_action" => "mark_seen"
      })

    messages_api()
    |> post(message)
  end

  def post_coins_search_question(recipient_id) do
    message =
      Jason.encode!(%{
        "recipient" => %{
          "id" => recipient_id
        },
        "message" => %{
          "attachment" => %{
            "type" => "template",
            "payload" => %{
              "template_type" => "button",
              "text" => "Do you want to search coins by name or by ID (Coins ID)?",
              "buttons" => [
                %{
                  "type" => "postback",
                  "title" => "Name",
                  "payload" => "SEARCH_BY_NAME"
                },
                %{
                  "type" => "postback",
                  "title" => "ID (Coins ID)",
                  "payload" => "SEARCH_BY_ID"
                }
              ]
            }
          }
        }
      })

    messages_api()
    |> post(message)
  end

  defp messenger_profile_api(), do: Application.get_env(:coin_gecko, :messenger_profile_api)
  defp messages_api(), do: Application.get_env(:coin_gecko, :messages_api)
  defp access_token(), do: Application.get_env(:coin_gecko, :webhook_token)
  defp graph_api(), do: Application.get_env(:coin_gecko, :graph)

  defp process_response_body({:ok, %HTTPoison.Response{body: body, status_code: 200}}),
    do: Jason.decode(body)

  defp process_response_body(_response), do: {:ok, ""}

  defp post(url, message) do
    headers = [{"Content-type", "application/json"}]

    (url <> "?access_token=" <> access_token())
    |> HTTPoison.post(message, headers, [])
    |> process_response_body()
  end
end
