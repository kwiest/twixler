defmodule Twixler.ApiTest do
  use ExUnit.Case
  doctest Twixler.Api

  test "parameterize_map" do
    params = %{"hello" => "world", "i_am" => "Twixler"}

    assert "?hello=world&i_am=Twixler" == Twixler.Api.parameterize_map(params)
  end

  test "parameterize_map with unsafe params" do
    params = %{"hey" => "i have spaces!"}

    assert "?hey=i%20have%20spaces!" == Twixler.Api.parameterize_map(params)
  end
end
