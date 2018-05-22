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

    {:ok, response} =
      case request.method do
        :get -> HTTPoison.get(url, headers, options)
        :post -> HTTPoison.post(url, headers, request.body, options)
        :put -> HTTPoison.put(url, headers, request.body, options)
        :delete -> HTTPoison.delete(url, headers, options)
      end

    format_response(response)
  end

  @spec format_response(HTTPoison.Response.t()) ::
          {:ok, String.t()}
          | {:ok, atom()}
          | {:ok, atom(), String.t()}
          | {:error, atom()}
          | {:error, atom(), String.t()}
  defp format_response(response) do
    case response.status_code do
      code when code in 200..204 -> success_response(response)
      code when code in 302..304 -> cached_response(response)
      code when code in 400..429 -> bad_request_response(response)
      code when code in 500..503 -> error_response(response)
    end
  end

  @spec success_response(HTTPoison.Response.t()) :: {:ok, String.t()} | {:ok, atom()}
  defp success_response(response) do
    case response.status_code do
      200 -> {:ok, response.body}
      201 -> {:ok, :created}
      204 -> {:ok, :deleted}
    end
  end

  @spec cached_response(HTTPoison.Response.t()) :: {:ok, atom(), String.t()}
  defp cached_response(response) do
    case response.status_code do
      302 -> {:ok, :found, get_header(response.headers, "Location")}
      304 -> {:ok, :not_modified, response.body}
    end
  end

  @spec bad_request_response(HTTPoison.Response.t()) ::
          {:error, :bad_request, String.t()} | {:error, atom()}
  defp bad_request_response(response) do
    case response.status_code do
      400 -> {:error, :bad_request, response.body}
      401 -> {:error, :unauthorized}
      404 -> {:error, :not_found}
      405 -> {:error, :method_not_allowed}
      429 -> {:error, :rate_limited}
    end
  end

  @spec error_response(HTTPoison.Response.t()) ::
          {:error, :server_error, String.t()} | {:error, atom()}
  defp error_response(response) do
    case response.status_code do
      500 -> {:error, :server_error, response.body}
      503 -> {:error, :service_unavailable}
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
