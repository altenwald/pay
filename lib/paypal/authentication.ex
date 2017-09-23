defmodule Paypal.Authentication do
  use Timex

  @moduledoc """
  This module is responsible to authenticate the lib with paypal.
  """

  def start_link(_type, _args) do
    Agent.start_link(fn -> %{token: nil, expires_in: -1} end, name: :token)
  end

  @doc """
  Function that returns a valid token. If the token has expired, it makes a call to paypal.
  """
  def get_token do
    if is_expired() do
      case request_token() do
        :ok -> {:ok, Agent.get(:token, &(&1))}
        _ -> {:error, "Could't request token"}
      end
    else
      {:ok, Agent.get(:token, &(&1))}
    end
  end

  defp is_expired do
    %{token: _, expires_in: expires } = Agent.get(:token, &(&1))
    :os.timestamp |> Duration.from_erl |> Duration.to_seconds > expires
  end

  defp get_env(key), do: Application.get_env(:pay, :paypal)[key]

  defp request_token do
    hackney = [basic_auth: { get_env(:client_id), get_env(:secret) }]
    with {:ok, response } <- HTTPoison.post(Paypal.Config.url <> "/oauth2/token", "grant_type=client_credentials", basic_headers(), [ hackney: hackney ]) |> Paypal.Config.parse_response(),
      do: parse_token(response) |> update_token()
  end

  defp update_token({:ok, access_token, expires_in}) do
    now = :os.timestamp |> Duration.from_erl |> Duration.to_seconds
    Agent.update(:token, fn _ -> %{token: access_token, expires_in: now + expires_in }  end)
  end

  defp parse_token (response) do
    {:ok, response["access_token"], response["expires_in"]}
  end

  @doc """
  Auth Headers needed to make a request to paypal.
  """

  def headers do
    case authorization_header() do
      {:ok, auth_header} -> {:ok, Enum.concat(request_headers(), auth_header)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp authorization_header do
    case get_token() do
      {:ok, %{token: access_token }} ->
        {:ok, [{"Authorization", "Bearer " <>  access_token}]}
      {:error, reason} ->
        {:error, reason}
    end    
  end
  defp request_headers(), do: [{"Accept", "application/json"}, {"Content-Type", "application/json"}]
  defp basic_headers(), do: [{"Accept", "application/json"}, {"Content-Type", "application/x-www-form-urlencoded"}]

end
