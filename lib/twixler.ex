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

  @doc """
  Hello world.

  ## Examples

      iex> Twixler.hello
      :world

  """
  def hello do
    :world
  end
end
