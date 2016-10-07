defmodule Paypal.Authentication do
  @moduledoc """
  This module is responsible to authenticate the lib with paypal.
  """

  def start_link do
    Agent.start_link(fn -> %{token: nil, expires_in: -1, status: nil} end, name: :token)
  end

  @doc """
  Function that returns a valid token. If the token has expired, it makes a call to paypal.
  """
  def token do
    if is_expired do
      request_token
    end
    Agent.get(:token, &(&1))
  end

  defp is_expired do
    %{token: _, expires_in: expires, status: _ } = Agent.get(:token, &(&1))
    :os.timestamp |> Timex.Time.to_seconds > expires
  end

  defp get_env(key), do: Application.get_env(:pay, :paypal)[key]

  defp request_token do
    hackney = [basic_auth: {get_env(:client_id), get_env(:secret)}]
    HTTPoison.post(Paypal.Config.url <> "/oauth2/token?grant_type=authorization_code", "grant_type=client_credentials", basic_headers, [ hackney: hackney ])
    |> Paypal.Config.parse_response
    |> parse_token
    |> update_token
  end

  defp update_token({type_error, response}) do
    Agent.update(:token, fn _ -> %{token: nil, expires_in: -1, status: {type_error, response}}  end)
  end

  defp update_token({:ok, access_token, expires_in}) do
    now = :os.timestamp |> Timex.Time.to_seconds
    Agent.update(:token, fn _ -> %{token: access_token, expires_in: now + expires_in, status: :ok}  end)
  end

  defp parse_token ({:ok, response}) do
    {:ok, response["access_token"], response["expires_in"]}
  end

  defp parse_token(error_response), do: error_response

  @doc """
  Auth Headers needed to make a request to paypal.
  """
  def headers do
    %{token: access_token, expires_in: _expires_in, status: status} = token
    case status do
      :ok ->
        {:ok, Enum.concat(request_headers, authorization_header(access_token))}
      error_response ->
        error_response
    end
  end

  def headers(token) do
    {:ok, Enum.concat(request_headers, authorization_header(token))}
  end

  defp authorization_header(access_token) do
    [{"Authorization", "Bearer " <>  access_token}]
  end
  defp request_headers, do: [{"Accept", "application/json"}, {"Content-Type", "application/json"}]
  defp basic_headers, do: [{"Accept", "application/json"}, {"Content-Type", "application/x-www-form-urlencoded"}]

end