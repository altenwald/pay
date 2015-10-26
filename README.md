[![Stories in Ready](https://badge.waffle.io/era/pay.png?label=ready&title=Ready)](https://waffle.io/era/pay)
Pay [Work in progress]
===

Pay is an Elixir Lib to deal with Paypal and other payment solutions. The lib's main goal is to be easy to extend other payment solutions.

It also uses Maru to receive the callback from the payment, so you don't need to worry about it. Just add the function that you want to run everytime that a payment is confirmed (or denied). {TODO}

Usage
-------

Creating a Payment (you must use the PaypalPayment struct):

```elixir
Payment.create_payment(%Paypal.Payment{intent: "authorize", payer: %{"funding_instruments" => [%{"credit_card" => %{"billing_address" => %{"city" => "Saratoga", "country_code" => "US", "line1" => "111 First Street", "postal_code" => "95070", "state" => "CA"}, "cvv2" => "874", "expire_month" => 11, "expire_year" => 2018, "first_name" => "Betsy", "last_name" => "Buyer", "number" => "4417119669820331", "type" => "visa"}}], "payment_method" => "credit_card"}, transactions: [%{"amount" => %{"currency" => "USD", "details" => %{"shipping" => "0.03", "subtotal" => "7.41", "tax" => "0.03"}, "total" => "7.47"}, "description" => "This is the payment transaction description."}]})

```

then add the `pay` to your `config/config.exs`
```elixir
config :pay, type: :paypal
```
And also your key from paypal:
```elixir
config :paypal, client_id: "EOJ2S-Z6OoN_le_KS1d75wsZ6y0SFdVsY9183IvxFyZp",
              secret: "EClusMEUk8e9ihI7ZdVLF5cZ6y0SFdVsY9183IvxFyZp",
              env: :prod
```

In your mix file:

```elixir
def deps do
  [{:pay, git: "https://github.com/era/pay.git"}]
end


def application do
  [applications: [:pay]]
end
```


Contributing
------------

  * Fork it
  * Create your feature branch (`git checkout -b my-new-feature`)
  * Create a Pull Request

TODO
---
* Support all Paypal API.
* Add pagar.me support.
* Add pagseguro support.

