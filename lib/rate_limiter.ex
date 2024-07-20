defmodule RateLimiter do
  @moduledoc """
  A simple rate limiter.
  """
  require Logger # enables us to use Logger macros
  alias ExRated # enables us to use ExRated's functions

  @login_request_limit 4 # login request limit per time window
  @time_window 600_000 # 10 minutes in milliseconds

  @doc """
    Check the login attempt rate limit for a given email address.

    iex> RateLimiter.allow_login_attempt?("doctest@example.com", 1)
    true

    iex> RateLimiter.allow_login_attempt?("doctest@example.com", 0)
    false
  """
  @spec allow_login_attempt?(String.t(), non_neg_integer()) :: boolean()
  def allow_login_attempt?(email, limit \\ @login_request_limit)
    when is_binary(email) and is_integer(limit) and limit >= 0
  do
    case ExRated.check_rate("login_attempt:#{email}", @time_window, limit) do
      {:ok, _count} -> true
      {:error, _limit} ->
        Logger.warning("Login attempt limit exceeded for email: #{email}")

        false
    end
  end
end
