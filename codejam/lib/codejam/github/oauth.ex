defmodule Codejam.Github.Oauth do
  require Logger
  require HTTPoison
  require Poison

  @doc """
  get_authorization_url
  Generate the url with scopes, state and client_id
  that user redirects to allow OAuth app and redirect
  back to service
  """
  def get_authorization_url(state) do
    oauth_config = Application.fetch_env!(:codejam, Codejam.Github.Oauth)

    oauth_url =
      "https://github.com/login/oauth/authorize?client_id=" <>
        oauth_config[:github_client_id] <>
        "&redirect_uri=" <>
        oauth_config[:github_redirect_uri] <> "&state=" <> state <> "&scope=repo read:user"

    oauth_url
  end
end
