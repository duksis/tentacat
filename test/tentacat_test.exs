defmodule TentacatTest do
  use ExUnit.Case
  import Tentacat

  doctest Tentacat

  setup_all do
    :meck.new(JSON, [:no_link])

    on_exit fn ->
      :meck.unload JSON
    end
  end

  test "authorization_header using user and password" do
    assert authorization_header(%{user: "user", password: "password"}, []) == [{"Authorization", "Basic dXNlcjpwYXNzd29yZA=="}]
  end

  test "authorization_header using access token" do
    assert authorization_header(%{access_token: "9820103"}, []) == [{"Authorization", "token 9820103"}]
  end

  test "process response on a 200 response" do
    :meck.expect(JSON, :decode!, 1, :decoded_json)
    assert process_response(%HTTPoison.Response{ status_code: 200,
                                                 headers: %{},
                                                 body: "json" }) == :decoded_json
    assert :meck.validate(JSON)
  end

  test "process response on a non-200 response" do
    :meck.expect(JSON, :decode!, 1, :decoded_json)
    assert process_response(%HTTPoison.Response{ status_code: 404,
                                                 headers: %{},
                                                 body: "json" }) == {404, :decoded_json}
    assert :meck.validate(JSON)
  end

  test "process response on a non-200 response and empty body" do
    assert process_response(%HTTPoison.Response{ status_code: 404,
                                                 headers: %{},
                                                 body: "" }) == {404, nil}
  end
end
