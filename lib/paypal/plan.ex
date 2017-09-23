defmodule Paypal.Plan do
  @derive [Poison.Encoder]
  defstruct id: nil, name: nil, description: nil, type: nil, payment_definitions: nil, merchant_preferences: nil
end

defimpl Plan, for: Paypal.Plan do

  def create(plan) do
    Task.async(fn -> do_create(plan) end)
  end

  defp do_create(plan) do
    string_plan = Poison.encode!(plan)
    with {:ok, headers} <- Paypal.Authentication.headers(),
      do: HTTPoison.post(Paypal.Config.url <> "/payments/billing-plans", string_plan, headers, timeout: :infinity, recv_timeout: :infinity)
        |> parse_response()
  end

  def update(plan) do
    Task.async fn -> do_update(plan) end
  end

  defp do_update(plan) do
    with {:ok, headers} <- Paypal.Authentication.headers(),
      do: HTTPoison.patch(Paypal.Config.url <> "/payments/billing-plans/#{plan.id}", Poison.encode!([%{path: "/", value: %{"state" => "ACTIVE"}, op: "replace"}]),
        headers, timeout: :infinity, recv_timeout: :infinity)
  end

  defp parse_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 401,  body: body, headers: _headers}} ->
        {:ok, response} = Poison.decode body
        {:auth_error, response}
      {:ok, %HTTPoison.Response{status_code: _, body: body, headers: _headers}} ->
        {:ok, Poison.decode! body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:nok, reason}
    end
  end

end
