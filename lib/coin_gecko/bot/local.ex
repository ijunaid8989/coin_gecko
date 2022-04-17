defmodule CoinGecko.Bot.Local do
  def set_get_started_with_greetings() do
    {:ok, %{"result" => "success"}}
  end

  def set_mark_seen(recipient_id) do
    {:ok, %{"recipient_id" => recipient_id}}
  end

  def post_coins_search_question(recipient_id) do
    {:ok,
     %{
       "message_id" => "message id",
       "recipient_id" => recipient_id
     }}
  end

  def post_random_reply(recipient_id, _reply) do
    {:ok,
     %{
       "message_id" => "message id",
       "recipient_id" => recipient_id
     }}
  end
end
