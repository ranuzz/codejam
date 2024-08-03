defmodule GithubClient do
  @moduledoc """
  Documentation for `GithubClient`.
  """
  require Logger
  require HTTPoison
  require Poison

  @api_base "https://api.github.com"

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
        # sample structure: {"access_token":"","token_type":"bearer","scope":""}
        {_, parsed_body} = Poison.decode(body)
        {:ok, %{token: parsed_body["access_token"], state: organization_id}}

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "Not Found"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      _ ->
        {:error, "Unknown Error"}
    end
  end

  @doc """
  list_repo
  get a list of public and private to choose from
  https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories
  """
  def list_repo(token) do
    case http_get(@api_base <> "/user/repos", get_headers(token)) do
      {:ok, response} -> Enum.each(response, &IO.puts(&1["url"]))
      {:error, reason} -> Logger.debug("#{inspect(reason)}")
    end
  end

  @doc """
  get user info
  TODO: add doc link
  """
  def user_info(token) do
    case http_get(@api_base <> "/user", get_headers(token)) do
      {:ok, response} ->
        response["login"]

      {:error, reason} ->
        Logger.debug("#{inspect(reason)}")
        nil
    end
  end

  @doc """
  https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28
  """
  def search_repo(token, query \\ "a") do
    user_id = user_info(token)

    case http_get(
           @api_base <> "/search/repositories?q=" <> query <> "+user:" <> user_id,
           get_headers(token)
         ) do
      {:ok, response} ->
        response

      {:error, reason} ->
        Logger.debug("#{inspect(reason)}")
        nil
    end
  end

  @doc """
  Get the latest commit for a given branch of a repository

  Uses list commit API to get the most recent result
  https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28#list-commits
  """
  def get_latest_commit_hash(token, owner, repo, branch \\ "main") do
    api_url =
      @api_base <> "/repos/" <> owner <> "/" <> repo <> "/commits?sha=" <> branch <> "&per_page=1"

    case http_get(api_url, get_headers(token)) do
      {:ok, response} ->
        %{"sha" => sha, "commit" => %{"tree" => %{"sha" => _tree}}} = hd(response)
        sha

      {:error, reason} ->
        Logger.debug("#{inspect(reason)}")
        nil
    end
  end

  @doc """
  https://docs.github.com/en/rest/git/commits?apiVersion=2022-11-28#get-a-commit-object
  """
  def get_commit(token, owner, repo, sha) do
    api_url = @api_base <> "/repos/" <> owner <> "/" <> repo <> "/git/commits/" <> sha

    case http_get(api_url, get_headers(token)) do
      {:ok, response} ->
        %{"sha" => _sha, "tree" => %{"sha" => tree}} = response
        tree

      {:error, reason} ->
        Logger.debug("#{inspect(reason)}")
        nil
    end
  end

  @doc """
  https://docs.github.com/en/rest/git/trees?apiVersion=2022-11-28#create-a-tree

  Sample output
  [
    %{type: "blob", path: ".gitignore", sha: "e14628c44d6efbb746032481552a7feea6571820"},
    %{type: "tree", path: "code", sha: "313a4d197749f1bddd66def83bd09734ce828c67"},
  ]
  """
  def get_tree(token, owner, repo, sha) do
    api_url = @api_base <> "/repos/" <> owner <> "/" <> repo <> "/git/trees/" <> sha

    case http_get(api_url, get_headers(token)) do
      {:ok, response} ->
        %{"sha" => _sha, "tree" => trees} = response
        Enum.map(trees, fn map -> %{sha: map["sha"], path: map["path"], type: map["type"]} end)

      {:error, reason} ->
        Logger.debug("#{inspect(reason)}")
        nil
    end
  end

  @doc """
  https://docs.github.com/en/rest/git/blobs?apiVersion=2022-11-28#get-a-blob
  """
  def get_blob(token, owner, repo, sha) do
    api_url = @api_base <> "/repos/" <> owner <> "/" <> repo <> "/git/blobs/" <> sha

    case http_get_raw(api_url, get_headers(token)) do
      {:ok, response} ->
        response

      {:error, reason} ->
        Logger.debug("#{inspect(reason)}")
        nil
    end
  end

  defp get_headers(token) do
    [
      {"content-type", "application/json"},
      {"Accept",
       "application/vnd.github+json, application/vnd.github.raw+json, application/json"},
      {"Authorization", "token #{token}"}
    ]
  end

  defp http_get(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {_, parsed_body} = Poison.decode(body)
        {:ok, parsed_body}

      {:ok, response} ->
        {_, parsed_body} = Poison.decode(response.body)
        {:error, parsed_body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp http_get_raw(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, response} ->
        {_, parsed_body} = Poison.decode(response.body)
        {:error, parsed_body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
