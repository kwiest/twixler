defmodule Twixler.Api do
  @moduledoc """
  Twixler Api client for making requests to Twilio and formatting responses.

  This module is meant to be used by other Twixler modules to wrap
  requests/responses around Twilio REST endpoints.
  """

  @api_base_url "https://api.twilio.com/2010-04-01"

  @spec make_request(Twixler.Request.t()) ::
          {:ok, String.t()}
          | {:ok, :not_modified}
          | {:ok, :found, String.t()}
          | {:error, atom()}
  def make_request(request) do
    url = @api_base_url <> request.path
    headers = build_headers(request.headers)
    options = build_options()

    response =
      case request.method do
        :get -> HTTPoison.get(url, headers, options)
        :post -> HTTPoison.post(url, headers, request.body, options)
        :put -> HTTPoison.put(url, headers, request.body, options)
        :delete -> HTTPoison.delete(url, headers, options)
      end

    format_response(response)
  end

  @spec format_response({atom(), HTTPoison.Response.t()}) ::
          {:ok, String.t()} | {:ok, :not_modified} | {:ok, :found, String.t()} | {:error, atom()}
  defp format_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 304, body: body}} ->
        {:ok, :not_modified, body}

      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
        location = get_header(headers, "Location")
        {:ok, :found, location}

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        {:error, :not_authorized}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}

      {:ok, %HTTPoison.Response{status_code: 429}} ->
        {:error, :rate_limited}

      {:ok, %HTTPoison.Response{status_code: 500}} ->
        {:error, :server_error}

      {:ok, %HTTPoison.Response{status_code: 503}} ->
        {:error, :service_unavailable}
    end
  end

  @spec build_headers(list(keyword())) :: list(keyword())
  defp build_headers(headers) do
    default_headers = [{"Content-Type", "application/json"}]

    Enum.into(headers, default_headers)
  end

  @spec build_options() :: list()
  defp build_options() do
    account_sid = Application.get_env(:twixler, :account_sid, "NO_ACCOUNT_SID_FOUND")
    auth_token = Application.get_env(:twixler, :auth_token, "NO_AUTH_TOKEN_FOUND")

    [hackney: [basic_auth: {account_sid, auth_token}], timeout: 30_000]
  end

  @spec get_header(Keyword.t(), String.t()) :: String.t()
  defp get_header(header_list, header) do
    for({key, value} <- header_list, key == header, do: value)
    |> List.first()
  end
end
