# Twixler

A client to interact with the [Twilio REST API](https://www.twilio.com/docs/iam/api) in Elixir.

The API is limited in functionality, but provides the ability to query metadata
about:
  - Your account
  - Phone numbers
  - Calls
  - Text messages

You can also create:
  - Outbound phone calls
  - SMS text messages

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `twixler` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:twixler, "~> 0.1.0"}
  ]
end
```

## Authentication

Twilio authenticates using HTTP Basic auth using your account SID and auth token
as username and password, respectively.

```elixir
config :twixler,
  account_sid: "MY_ACCOUNT_SID",
  auth_token: "MY_AUTH_TOKEN"
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/twixler](https://hexdocs.pm/twixler).

