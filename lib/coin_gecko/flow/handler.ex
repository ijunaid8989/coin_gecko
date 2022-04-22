defmodule CoinGecko.Flow.Handler do
  alias CoinGecko.Flow.{Supervisor, State}

  require Logger

  def init(recipient_id) do
    Registry.lookup(StateRegistry, "state_for_#{recipient_id}")
    |> case do
      [{pid, _nil}] -> Supervisor.terminate(pid)
      _ -> Logger.debug("No State process found for #{recipient_id}")
    end

    Supervisor.start_child(State, %{id: recipient_id, current_state: "GET_STARTED_PAYLOAD"})

    post_coin_question(recipient_id)
  end

  def search_payload(recipient_id, payload) do
    init_for_state(recipient_id)
    State.update_state(recipient_id, %{current_state: "SAERCH_BY_NAME_OR_ID", payload: payload})

    ask_for_coin_name_or_id(recipient_id, payload)
  end

  def init_for_state(recipient_id) do
    Registry.lookup(StateRegistry, "state_for_#{recipient_id}")
    |> case do
      [{_pid, _nil}] ->
        Logger.debug("State process found for #{recipient_id}")

      _ ->
        Supervisor.start_child(State, %{id: recipient_id, current_state: "GET_STARTED_PAYLOAD"})
    end
  end

  def random_reply(recipient_id, text \\ nil) do
    Registry.lookup(StateRegistry, "state_for_#{recipient_id}")
    |> case do
      [{_pid, _nil}] ->
        %{current_state: current_state} = state = State.get_state(recipient_id)

        case current_state do
          "GET_STARTED_PAYLOAD" -> post_coin_question(recipient_id)
          "SAERCH_BY_NAME_OR_ID" -> search_coins_and_reply(recipient_id, text)
          "MAX_5_COIN_SENT" -> respond_with_coins(recipient_id, state.coins)
          "SENT_ID_COIN_DETAILS" -> post_coin_question(recipient_id)
          _ -> :ok
        end

      _ ->
        first_name = get_first_name(recipient_id)

        bot().post_random_reply(
          recipient_id,
          "Hello #{first_name}! How are you doing today?"
        )

        init(recipient_id)
    end
  end

  def send_coins_listings(recipient_id, coin_id) do
    with {:ok, prices} <- wrapper().market_chart(coin_id) do
      Enum.map(prices, fn price ->
        price_time(price)
      end)
      |> List.flatten()
      |> Enum.chunk_every(50)
      |> Enum.each(fn chunk ->
        reply =
          chunk
          |> Enum.join("")

        bot().post_random_reply(
          recipient_id,
          reply
        )
      end)

      init_for_state(recipient_id)
      State.update_state(recipient_id, %{current_state: "SENT_ID_COIN_DETAILS"})
    end
  end

  defp price_time([time, price]) do
    [
      "#{DateTime.from_unix!(time, :millisecond) |> DateTime.to_iso8601()}, USD: #{Float.ceil(price, 3)}.\n\n"
    ]
  end

  defp bot(), do: Application.get_env(:coin_gecko, :bot_messaging)
  defp wrapper(), do: Application.get_env(:coin_gecko, :api_wrapper)

  defp post_coin_question(recipient_id) do
    bot().set_mark_seen(recipient_id)
    bot().post_coins_question(recipient_id)
  end

  defp ask_for_coin_name_or_id(recipient_id, payload) do
    post_random_reply(recipient_id, "Please enter Coin's " <> String.capitalize(payload) <> ".")
  end

  defp search_coins_and_reply(recipient_id, text) do
    %{current_state: _current_state, payload: payload} = State.get_state(recipient_id)
    results = wrapper().search(text, payload)

    with {:ok, coins} <- results,
         false <- is_list(coins) do
      post_random_reply(
        recipient_id,
        "Retrieving prices in USD for the last 14 days for coin ID #{text}."
      )

      State.update_state(recipient_id, %{current_state: "SENT_ID_COIN_DETAILS"})
      send_coins_listings(recipient_id, coins["id"])
    else
      true ->
        {:ok, coins} = results

        State.update_state(recipient_id, %{current_state: "MAX_5_COIN_SENT", coins: coins})
        respond_with_coins(recipient_id, coins)

      {:error, :not_found} ->
        post_random_reply(recipient_id, "Nothing found on CoinGecko for coin: #{text}.")
        post_coin_question(recipient_id)
    end
  end

  defp get_first_name(recipient_id) do
    bot().get_user_details(recipient_id)
    |> case do
      {:ok, %{"first_name" => first_name, "id" => ^recipient_id}} -> first_name
      _ -> "Unknown"
    end
  end

  defp post_random_reply(recipient_id, reply) do
    bot().set_mark_seen(recipient_id)

    bot().post_random_reply(
      recipient_id,
      reply
    )
  end

  defp respond_with_coins(recipient_id, coins) do
    quick_replies =
      Enum.map(coins, fn coin ->
        %{
          "content_type" => "text",
          "title" => coin["name"],
          "payload" => coin["id"],
          "image_url" => coin["thumb"]
        }
      end)

    bot().post_quick_reply(recipient_id, "Please choose a coin.", quick_replies)
  end
end
