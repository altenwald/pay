defmodule Paypal.PaymentTest do
  use ExUnit.Case
  use Timex
  import Mock
  @tag timeout: :infinity

  test "create and get payment" do
    Paypal.App.start([],[])
    now = :os.timestamp |> Duration.from_erl |> Duration.to_seconds
    Agent.update(:token, fn _ -> %{token: "anything", expires_in: now + 100000 }  end)
    with_mock HTTPoison, [post: fn(_url, _headers, _, _) -> {:ok, %HTTPoison.Response{status_code: 200,  body: ~s({"id":"PAY-17S8410768582940NKEE66EQ","create_time":"2013-01-31T04:12:02Z","update_time":"2013-01-31T04:12:04Z","state":"approved","intent":"sale","payer":{"payment_method":"credit_card","funding_instruments":[{"credit_card":{"type":"visa","number":"xxxxxxxxxxxx0331","expire_month":"11","expire_year":"2018","first_name":"Betsy","last_name":"Buyer","billing_address":{"line1":"111 First Street","city":"Saratoga","state":"CA","postal_code":"95070","country_code":"US"}}}]},"transactions":[{"amount":{"total":"7.47","currency":"USD","details":{"tax":"0.03","shipping":"0.03"}},"description":"This is the payment transaction description.","related_resources":[{"sale":{"id":"4RR959492F879224U","create_time":"2013-01-31T04:12:02Z","update_time":"2013-01-31T04:12:04Z","state":"completed","amount":{"total":"7.47","currency":"USD"},"parent_payment":"PAY-17S8410768582940NKEE66EQ","links":[{"href":"https://api.sandbox.paypal.com/v1/payments/sale/4RR959492F879224U","rel":"self","method":"GET"},{"href":"https://api.sandbox.paypal.com/v1/payments/sale/4RR959492F879224U/refund","rel":"refund","method":"POST"},{"href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-17S8410768582940NKEE66EQ","rel":"parent_payment","method":"GET"}]}}]}],"links":[{"href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-17S8410768582940NKEE66EQ","rel":"self","method":"GET"}]}), headers: []}} end] do

      {:ok, result} = Task.await(Payment.create_payment(%Paypal.Payment{intent: "sale", payer: %{"funding_instruments" => [%{"credit_card" => %{"billing_address" => %{"city" => "Saratoga", "country_code" => "US", "line1" => "111 First Street", "postal_code" => "95070", "state" => "CA"}, "cvv2" => "874", "expire_month" => 11, "expire_year" => 2018, "first_name" => "Betsy", "last_name" => "Buyer", "number" => "4417119669820331", "type" => "visa"}}], "payment_method" => "credit_card"}, transactions: [%{"amount" => %{"currency" => "USD", "details" => %{"shipping" => "0.03", "subtotal" => "7.41", "tax" => "0.03"}, "total" => "7.47"}, "description" => "This is the payment transaction description."}]}), 10000000)
      assert "approved" == result["state"]
    end

    with_mock HTTPoison, [get: fn(_url, _headers, _) -> {:ok, %HTTPoison.Response{status_code: 200,  body: ~s({"id":"PAY-5YK922393D847794YKER7MUI","create_time":"2013-02-19T22:01:53Z","update_time":"2013-02-19T22:01:55Z","state":"approved","intent":"sale","payer":{"payment_method":"credit_card","funding_instruments":[{"credit_card":{"type":"mastercard","number":"xxxxxxxxxxxx5559","expire_month":"2","expire_year":"2018","first_name":"Betsy","last_name":"Buyer"}}]},"transactions":[{"amount":{"total":"7.47","currency":"USD","details":{"subtotal":"7.47"}},"description":"This is the payment transaction description.","related_resources":[{"sale":{"id":"36C38912MN9658832","create_time":"2013-02-19T22:01:53Z","update_time":"2013-02-19T22:01:55Z","state":"completed","amount":{"total":"7.47","currency":"USD"},"protection_eligibility":"ELIGIBLE","protection_eligibility_type":"UNAUTHORIZED_PAYMENT_ELIGIBLE","transaction_fee":{"value":"1.75","currency":"USD"},"parent_payment":"PAY-5YK922393D847794YKER7MUI","links":[{"href":"https://api.sandbox.paypal.com/v1/payments/sale/36C38912MN9658832","rel":"self","method":"GET"},{"href":"https://api.sandbox.paypal.com/v1/payments/sale/36C38912MN9658832/refund","rel":"refund","method":"POST"},{"href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-5YK922393D847794YKER7MUI","rel":"parent_payment","method":"GET"}]}}]}],"links":[{"href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-5YK922393D847794YKER7MUI","rel":"self","method":"GET"}]}), headers: []}} end] do
      {:ok, status} = Payment.get_status %Paypal.Payment{id: "PAY-5YK922393D847794YKER7MUI"}
      assert "approved" == status["state"]
    end
  end

  test "get a list of payments" do
    Paypal.App.start([],[])
    now = :os.timestamp |> Duration.from_erl |> Duration.to_seconds
    Agent.update(:token, fn _ -> %{token: "anything", expires_in: now + 100000 }  end)
    with_mock HTTPoison, [get: fn(_url, _headers, _) -> {:ok, %HTTPoison.Response{status_code: 200,  body: ~s({"payments":[{"id":"PAY-4D099447DD202993VKEFMRJQ","create_time":"2013-01-31T19:40:22Z","update_time":"2013-01-31T19:40:24Z","state":"approved","intent":"sale","payer":{"payment_method":"credit_card","funding_instruments":[{"credit_card":{"type":"visa","number":"xxxxxxxxxxxx0331","expire_month":"10","expire_year":"2018","first_name":"Betsy","last_name":"Buyer","billing_address":{"line1":"111 First Street","city":"Saratoga","state":"CA","postal_code":"95070","country_code":"US"}}}]},"transactions":[{"amount":{"total":"110.54","currency":"USD"},"description":"This is the payment transaction description.","related_resources":[{"sale":{"id":"1D971400A7097562W","create_time":"2013-01-31T19:40:23Z","update_time":"2013-01-31T19:40:25Z","state":"completed","amount":{"total":"110.54","currency":"USD"},"parent_payment":"PAY-4D099447DD202993VKEFMRJQ","links":[{"href":"https://api.sandbox.paypal.com/v1/payments/sale/1D971400A7097562W","rel":"self","method":"GET"},{"href":"https://api.sandbox.paypal.com/v1/payments/sale/1D971400A7097562W/refund","rel":"refund","method":"POST"},{"href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-4D099447DD202993VKEFMRJQ","rel":"parent_payment","method":"GET"}]}}]}],"links":[{"href":"https://api.sandbox.paypal.com/v1/payments/payment/PAY-4D099447DD202993VKEFMRJQ","rel":"self","method":"GET"}]}]}), headers: []}} end] do
      assert {:ok, _} = Payment.get_payments(%Paypal.Payment{})
    end

  end

#  @tag timeout: :infinity
 # test "Update a payment" do
 #   Paypal.App.start([],[])

   # {:ok, result} = Task.await(Payment.create_payment(%Paypal.Payment{intent: "authorize", payer: %{"funding_instruments" => [%{"credit_card" => %{"billing_address" => %{"city" => "Saratoga", "country_code" => "US", "line1" => "111 First Street", "postal_code" => "95070", "state" => "CA"}, "cvv2" => "874", "expire_month" => 11, "expire_year" => 2018, "first_name" => "Betsy", "last_name" => "Buyer", "number" => "4417119669820331", "type" => "visa"}}], "payment_method" => "credit_card"}, transactions: [%{"amount" => %{"currency" => "USD", "details" => %{"shipping" => "0.03", "subtotal" => "7.41", "tax" => "0.03"}, "total" => "7.47"}, "description" => "This is the payment transaction description."}]}), 10000000)
   ## {:ok, payment} = Payment.update_payment %Paypal.Payment{id: result["id"], update: []} # update: [%{"op" => "replace", "path" => "/transactions/0/amount", "value" => %{"currency" => "EUR", "details" => %{"shipping" => "5.00", "subtotal" => "13.37"}, "total" => "18.37"}}]
    #IO.puts inspect payment
    #assert result["id"] == payment["id"]
  #end
end
