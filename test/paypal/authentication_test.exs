defmodule Paypal.AuthenticationTest do
  use ExUnit.Case
  import Mock
  test "get token" do
    with_mock HTTPoison, [post: fn(_url, _headers, _, _) -> {:ok, %HTTPoison.Response{status_code: 200,  body: ~s({
        "scope": "https://api.paypal.com/v1/payments/.* https://api.paypal.com/v1/vault/credit-card https://api.paypal.com/v1/vault/credit-card/.*",
        "access_token": "EEwJ6tF9x5WCIZDYzyZGaz6Khbw7raYRIBV_WxVvgmsG",
        "token_type": "Bearer",
        "app_id": "APP-6XR95014BA15863X",
        "expires_in": 28800
      }), headers: []}} end] do
      Paypal.App.start([],[])
      assert {:ok, %{token: token, expires_in: _}} = Paypal.Authentication.get_token()

      assert {:ok, [
        {"Accept", "application/json"},
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer " <> token}
      ]} == Paypal.Authentication.headers()
    end
  end
end
