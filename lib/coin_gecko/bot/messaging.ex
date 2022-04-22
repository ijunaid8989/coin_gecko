defmodule CoinGecko.Bot.Messaging do
  @spec set_get_started_with_greetings() :: {:ok, map()}
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

  @type user :: %{first_name: String.t(), id: String.t()}
  @spec get_user_details(recipient_id :: String.t()) :: {:ok, user()}
  def get_user_details(recipient_id) do
    (graph_api() <> "/" <> recipient_id <> "?fields=first_name")
    |> get()
  end

  @spec set_mark_seen(recipient_id :: String.t()) :: {:ok, any()}
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

  @type reply :: %{message_id: String.t(), recipient_id: String.t()}
  @spec post_random_reply(recipient_id :: String.t(), reply :: String.t()) :: {:ok, reply()}
  def post_random_reply(recipient_id, reply) do
    message =
      Jason.encode!(%{
        "messaging_type" => "RESPONSE",
        "recipient" => %{
          "id" => recipient_id
        },
        "message" => %{
          "text" => reply
        }
      })

    messages_api()
    |> post(message)
  end

  @type reply :: %{message_id: String.t(), recipient_id: String.t()}
  @spec post_coins_question(recipient_id :: String.t(), title :: String.t(), buttons :: map()) ::
          {:ok, reply()}
  def post_coins_question(
        recipient_id,
        title \\ default_title(),
        buttons \\ default_buttons()
      ) do
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
              "text" => title,
              "buttons" => buttons
            }
          }
        }
      })

    messages_api()
    |> post(message)
    |> IO.inspect()
  end

  @type reply :: %{message_id: String.t(), recipient_id: String.t()}
  @spec post_coins_question(
          recipient_id :: String.t(),
          text :: String.t(),
          quick_replies :: [map()]
        ) :: {:ok, reply()}
  def post_quick_reply(recipient_id, text, quick_replies) do
    message =
      Jason.encode!(%{
        "recipient" => %{
          "id" => recipient_id
        },
        "messaging_type" => "RESPONSE",
        "message" => %{
          "text" => text,
          "quick_replies" => quick_replies
        }
      })

    messages_api()
    |> post(message)
  end

  defp messenger_profile_api(), do: Application.get_env(:coin_gecko, :messenger_profile_api)
  defp messages_api(), do: Application.get_env(:coin_gecko, :messages_api)
  defp access_token(), do: Application.get_env(:coin_gecko, :webhook_token)
  defp graph_api(), do: Application.get_env(:coin_gecko, :graph_api)

  defp process_response_body({:ok, %HTTPoison.Response{body: body, status_code: 200}}),
    do: Jason.decode(body)

  defp process_response_body(_response), do: {:ok, ""}

  defp get(url) do
    headers = [{"Content-type", "application/json"}]

    (url <> "&access_token=" <> access_token())
    |> HTTPoison.get(headers)
    |> process_response_body()
  end

  defp post(url, message) do
    headers = [{"Content-type", "application/json"}]

    (url <> "?access_token=" <> access_token())
    |> HTTPoison.post(message, headers, [])
    |> process_response_body()
  end

  defp default_buttons(),
    do: [
      %{
        "type" => "postback",
        "title" => "Name",
        "payload" => "NAME"
      },
      %{
        "type" => "postback",
        "title" => "ID (Coin's ID)",
        "payload" => "ID"
      }
    ]

  defp default_title(), do: "Do you want to search coins by name or by ID (Coin's ID)?"
end
