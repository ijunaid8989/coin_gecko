defmodule CoinGecko.Bot.MessagingTest do
  use CoinGeckoWeb.ConnCase

  setup do
    [
      recipient_id: "12345",
      bot: Application.get_env(:coin_gecko, :bot_messaging)
    ]
  end

  describe "Messaging" do
    test "set_get_started_with_greetings", %{bot: bot} do
      {:ok, response} = bot.set_get_started_with_greetings()

      resp = %{"result" => "success"}

      assert resp == response
    end

    test "get_user_details", %{bot: bot, recipient_id: recipient_id} do
      {:ok, %{"first_name" => _somename, "id" => id}} = bot.get_user_details(recipient_id)

      assert id == recipient_id
    end

    test "set_mark_seen", %{bot: bot, recipient_id: recipient_id} do
      {:ok, resp} = bot.set_mark_seen(recipient_id)

      assert %{"recipient_id" => ^recipient_id} = resp
    end

    test "post_random_reply", %{bot: bot, recipient_id: recipient_id} do
      assert {:ok,
              %{
                "message_id" => _message_id,
                "recipient_id" => ^recipient_id
              }} = bot.post_random_reply(recipient_id, "hello, reply")
    end

    test "post_coins_question", %{bot: bot, recipient_id: recipient_id} do
      {:ok,
       %{
         "message_id" => "message id",
         "recipient_id" => ^recipient_id
       }} =
        bot.post_coins_question(recipient_id, "Its a title", [
          %{
            "type" => "postback",
            "title" => "Hello",
            "payload" => "GREET"
          }
        ])
    end

    test "post_quick_reply", %{bot: bot, recipient_id: recipient_id} do
      {:ok,
       %{
         "message_id" => "message_id",
         "recipient_id" => ^recipient_id
       }} =
        bot.post_quick_reply(recipient_id, "its text", [
          %{
            "content_type" => "text",
            "title" => "I am title",
            "payload" => "TITLE",
            "image_url" => "www.image.url.com"
          }
        ])
    end
  end
end
