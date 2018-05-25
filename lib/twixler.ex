defmodule Twixler.Request do
  @moduledoc """
  Request types for building requests to send to Twilio.
  """

  defstruct(method: nil, headers: [], path: nil, body: nil)
  @type method :: :get | :put | :post | :delete
  @type t :: %__MODULE__{
          method: method(),
          headers: Keyword.t(),
          path: String.t(),
          body: String.t()
        }
end

defmodule Twixler do
  @moduledoc """
  Documentation for Twixler.
  """

  def account_sid() do
    Application.get_env(:twixler, :account_sid, "NO_ACCOUNT_SID_FOUND")
  end

  def auth_token() do
    Application.get_env(:twixler, :auth_token, "NO_AUTH_TOKEN_FOUND")
  end
end
