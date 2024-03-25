defmodule Codejam.Integrations.Github.Oauth do
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

  @doc """
  get_access_token
  use OAuth authorization code to get access token
  create and intergration row if does not exist
  update the integration row if it exist

  params structure
  %{
      "code" => "{code}",
      "state" => "{organization_id}"
  }
  """
  def get_access_token(params) do
    code = params["code"]
    organization_id = params["state"]
    oauth_config = Application.fetch_env!(:codejam, Codejam.Github.Oauth)

    {_, body} =
      Poison.encode(%{
        "client_id" => "#{oauth_config[:github_client_id]}",
        "client_secret" => "#{oauth_config[:github_client_secret]}",
        "redirect_uri" => "#{oauth_config[:github_redirect_uri]}",
        "code" => "#{code}"
      })

    case HTTPoison.post(
           "https://github.com/login/oauth/access_token",
           body,
           [{"content-type", "application/json"}, {"Accept", "application/json"}]
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # {"access_token":"","token_type":"bearer","scope":""}
        {_, parsed_body} = Poison.decode(body)

        Codejam.Integrations.Integration.add_integration(
          "github",
          parsed_body["access_token"],
          organization_id
        )

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.debug("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.debug(reason)

      response ->
        Logger.debug(response)
    end
  end
end
