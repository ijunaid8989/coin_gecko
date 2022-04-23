defmodule CoinGecko.Bot.Local do
  def set_get_started_with_greetings() do
    {:ok, %{"result" => "success"}}
  end

  def get_user_details(recipient_id) do
    {:ok, %{"first_name" => "first_name", "id" => recipient_id}}
  end

  def set_mark_seen(recipient_id) do
    {:ok, %{"recipient_id" => recipient_id}}
  end

  def post_coins_question(
        recipient_id,
        _title,
        buttons
      ) do
    case length(buttons) <= 3 do
      true ->
        {:ok,
         %{
           "message_id" => "message id",
           "recipient_id" => recipient_id
         }}

      false ->
        {:error,
         %{
           "error" => %{
             "code" => 105,
             "message" => "(#105) param name_placeholder[buttons] has too many elements.",
             "type" => "OAuthException"
           }
         }}
    end
  end

  def post_coins_search_question(recipient_id, _title, _buttons) do
    {:ok,
     %{
       "message_id" => "message id",
       "recipient_id" => recipient_id
     }}
  end

  def post_random_reply(recipient_id, reply) do
    case String.length(reply) <= 2000 do
      true ->
        {:ok,
         %{
           "message_id" => "message id",
           "recipient_id" => recipient_id
         }}

      false ->
        {:error,
         %{
           "error" => %{
             "code" => 100,
             "message" =>
               "(#100) Length of param message[text] must be less than or equal to 2000",
             "type" => "OAuthException"
           }
         }}
    end
  end

  def post_quick_reply(recipient_id, _text, _quick_replies) do
    {:ok,
     %{
       "message_id" => "message_id",
       "recipient_id" => recipient_id
     }}
  end
end
