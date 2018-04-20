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
    %{expires_in: expires} = Agent.get(:token, &(&1))
    System.os_time(:seconds) > expires
  end

  defp get_env(key) do
    case Application.get_env(:pay, :paypal)[key] do
      nil -> raise "Expected #{key} to be set"
      {:system, var} -> System.get_env(var) || raise "Expected #{var} to be set"
      value -> value
    end
  end

  defp request_token do
    hackney = [basic_auth: {get_env(:client_id), get_env(:secret)}]
    with {:ok, response} <- HTTPoison.post(Paypal.Config.url <> "/oauth2/token" <>
                                           "?grant_type=client_credentials",
                                           "grant_type=authorization_code",
                                           basic_headers(), [ hackney: hackney ])
                            |> Paypal.Config.parse_response() do
      response
      |> parse_token()
      |> update_token()
    end
  end

  defp update_token({type_error, response}) do
    Agent.update(:token, fn _ -> %{token: nil, expires_in: -1, status: {type_error, response}}  end)
  end

  defp update_token({:ok, access_token, expires_in}) do
    now = System.os_time(:seconds)
    Agent.update(:token, fn _ -> %{token: access_token, expires_in: now + expires_in, status: :ok}  end)
  end

  defp parse_token(response) do
    {:ok, response["access_token"], response["expires_in"]}
  end

  @doc """
  Auth Headers needed to make a request to paypal.
  """
  def headers do
    with %{token: access_token, status: :ok} = get_token() do
      {:ok, Enum.concat(request_headers(), authorization_header(access_token))}
    end
  end

  def headers(token) do
    {:ok, Enum.concat(request_headers(), authorization_header(token))}
  end

  defp authorization_header(access_token) do
    [{"Authorization", "Bearer " <>  access_token}]
  end

  defp request_headers(), do: [{"Accept", "application/json"}, {"Content-Type", "application/json"}]
  defp basic_headers(), do: [{"Accept", "application/json"}, {"Content-Type", "application/x-www-form-urlencoded"}]
end
