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
      assert {:ok,
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
      assert {:ok,
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

    test "failed to post_coins_question when buttons are more than 3", %{
      bot: bot,
      recipient_id: recipient_id
    } do
      expected_error = "(#105) param name_placeholder[buttons] has too many elements."
      expected_error_code = 105
      error_type = "OAuthException"

      {:error,
       %{
         "error" => error
       }} =
        bot.post_coins_question(recipient_id, "Its a title", [
          %{
            "type" => "postback",
            "title" => "Hello",
            "payload" => "GREET"
          },
          %{
            "type" => "postback",
            "title" => "Hello",
            "payload" => "GREET"
          },
          %{
            "type" => "postback",
            "title" => "Hello",
            "payload" => "GREET"
          },
          %{
            "type" => "postback",
            "title" => "Hello",
            "payload" => "GREET"
          }
        ])

      assert ^expected_error = error["message"]
      assert ^error_type = error["type"]
      assert ^expected_error_code = error["code"]
    end

    test "failed to post_random_reply when reply text length is more than 2000", %{
      bot: bot,
      recipient_id: recipient_id
    } do
      expected_error = "(#100) Length of param message[text] must be less than or equal to 2000"
      expected_error_code = 100
      error_type = "OAuthException"

      {:error,
       %{
         "error" => error
       }} = bot.post_random_reply(recipient_id, String.duplicate("hello, reply", 2000))

      assert ^expected_error = error["message"]
      assert ^error_type = error["type"]
      assert ^expected_error_code = error["code"]
    end
  end
end
