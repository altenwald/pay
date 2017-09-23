defmodule Paypal.Agreement do
  @derive [Poison.Encoder]
  defstruct id: nil, state: nil, name: nil, description: nil, start_date: nil, agreement_details: nil, payer: nil, plan: nil, shipping_address: nil
end

defimpl Agreement, for: [Paypal.Agreement, BitString] do
  def create(agreement) do
    Task.async(fn -> do_create(agreement) end)
  end

  defp do_create(agreement) do
    string_agreement = Poison.encode!(agreement)
    with {:ok, headers } <- Paypal.Authentication.headers(),
      do: HTTPoison.post(Paypal.Config.url <> "/payments/billing-agreements", string_agreement, headers, timeout: :infinity, recv_timeout: :infinity)
          |> Paypal.Config.parse_response
  end

  def execute(token) do
    Task.async fn -> do_execute(token) end
  end

  defp do_execute(token) do
    with {:ok, headers} <- Paypal.Authentication.headers(),
      do: HTTPoison.post(Paypal.Config.url <> "/payments/billing-agreements/#{token}/agreement-execute", "{}", headers, timeout: :infinity, recv_timeout: :infinity)
        |> Paypal.Config.parse_response
  end
end
