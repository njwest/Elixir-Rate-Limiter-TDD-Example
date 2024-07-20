defmodule RateLimiterTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias RateLimiter

  @test_email "test@example.com"
  @limit 2

  setup do
    # Empty the login attempt bucket for @test_email before each test
    ExRated.delete_bucket("login_attempt:#{@test_email}")
    :ok
  end

  # Run the doctests in @doc declarations in RateLimiter
  doctest RateLimiter

  test "allow_login_attempt?/2 returns true while under the limit" do
    assert RateLimiter.allow_login_attempt?(@test_email, @limit) == true
    assert RateLimiter.allow_login_attempt?(@test_email, @limit) == true
  end

  test "allow_login_attempt?/2 returns false with a warning log when over the login attempt limit" do
    assert RateLimiter.allow_login_attempt?(@test_email, @limit) == true
    assert RateLimiter.allow_login_attempt?(@test_email, @limit) == true

    log = capture_log(fn ->
      assert RateLimiter.allow_login_attempt?(@test_email, @limit) == false
    end)

    assert log =~ "Login attempt limit exceeded for email: #{@test_email}"
  end
end
