defmodule Codejam.Github.Api do
  require Logger
  require HTTPoison
  require Poison

  import Ecto.Query, only: [from: 2]

  alias Codejam.Github.Crawl
  alias Codejam.Repo
  alias Codejam.Integration

  @github_api_list_repos "https://api.github.com/user/repos"
  @github_api_search_repos "https://api.github.com/search/repositories?q="
  @github_get_user_info "https://api.github.com/user"
  @github_download_local_dir "tmp/"

  @doc """
  list_repo
  get a list of public and private to choose from
  https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-organization-repositories
  """
  def list_repo(organization_id) do
    with {:ok, access_token} <- get_token(organization_id),
         {:ok, response} <-
           http_get(@github_api_list_repos, get_headers(access_token)) do
      # Logger.debug("#{inspect(response)}")
      Enum.each(response, &IO.puts(&1["url"]))
    end
  end

  @doc """
  get user info
  TODO: add doc link
  """
  def user_info(organization_id) do
    with {:ok, access_token} <- get_token(organization_id),
         {:ok, response} <-
           http_get(@github_get_user_info, get_headers(access_token)) do
      # Logger.debug("#{inspect(response)}")
      # Enum.each(response, &IO.puts(&1["url"]))
      {:ok, response["login"]}
    end
  end

  @doc """
  https://docs.github.com/en/rest/search/search?apiVersion=2022-11-28
  """
  def search_repo(organization_id, query \\ "a") do
    with {:ok, access_token} <- get_token(organization_id),
         {:ok, user_id} <- user_info(organization_id),
         {:ok, response} <-
           http_get(
             @github_api_search_repos <>
               query <>
               "+user:" <> user_id,
             get_headers(access_token)
           ) do
      # Enum.each(response, &IO.puts(&1["url"]))
      {:ok, response}
    end
  end

  @doc """
  get most recent commits for repo and branch
  https://docs.github.com/en/rest/commits/commits?apiVersion=2022-11-28
  """
  def get_repo_branch_commits(organization_id, commits_url, branch \\ "main") do
    with {:ok, access_token} <- get_token(organization_id),
         {:ok, response} <-
           http_get(
             String.replace(commits_url, "{/sha}", "/" <> branch),
             get_headers(access_token)
           ) do
      # Enum.each(response, &IO.puts(&1["url"]))
      {:ok, response["sha"]}
    end
  end

  # def add_project(url, name, branch, organization_id) do
  #   {_, project} = Codejam.Project.add_project(url, name, organization_id)
  #   {_, project} = Codejam.Project.add_project(url, name, organization_id)
  #   Canvas.add_snapshot(branch, "", "", project.id, organization_id)
  # end

  @doc """
  download repo
  https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28#download-a-repository-archive-zip
  """
  def download_repo(api_url, branch, snapshot_id, snapshot_sha, organization_id) do
    download_api_url = api_url <> "/zipball/" <> branch

    with {:ok, access_token} <- get_token(organization_id),
         {:ok, download_location} <-
           http_get_redirect(download_api_url, get_headers(access_token)) do
      Logger.debug(download_location)

      case http_get_download(download_location) do
        {:ok, data} ->
          zip_location = @github_download_local_dir <> snapshot_sha <> ".zip"
          extracted_location = @github_download_local_dir <> snapshot_sha
          # download Zip file
          File.write(zip_location, data)
          # Unzip
          System.cmd("unzip", [zip_location, "-d", extracted_location])
          # cleanup
          System.cmd("rm", [zip_location])

          # Create file tree
          file_tree = Crawl.crawl(extracted_location)

          IO.inspect(file_tree)

          Codejam.Github.Crawl.FileTree.create_inodes(
            file_tree,
            nil,
            snapshot_id,
            organization_id
          )

        _ ->
          IO.puts("oops")
      end
    end
  end

  # def create_inodes_for_snapshot(path, snapshot_id, organization_id) do
  #   Crawl.crawl(path)
  # end

  @doc """
  list_branches
  get a list of branches given a repo
  """
  def list_branches do
  end

  @doc """
  get_repo_info
  get detailed info about a repo given branch
  """
  def get_repo_info do
  end

  @doc """
  add_repo
  add a repo as project for the given integration and branch
  create a project row
  do nothing on conflict
  """
  def add_repo do
  end

  @doc """
  configure_webhook
  configure webhook to receive updates on lates commit
  given a project.
  https://docs.github.com/en/rest/repos/webhooks?apiVersion=2022-11-28#create-a-repository-webhook
  """
  def configure_webhook do
  end

  @doc """
  create_snapshot
  on receiving a webhook create a snapshot for the project
  """
  def create_snapshot do
  end

  defp get_token(organization_id) do
    integrations = Repo.all(from(Integration, where: [organization_id: ^organization_id]))

    if Kernel.length(integrations) === 0 do
      {:error, "no integrations"}
    end

    {:ok, hd(integrations).access_token}
  end

  defp get_headers(access_token) do
    [
      {"content-type", "application/json"},
      {"Accept", "application/vnd.github+json, application/json"},
      {"Authorization", "token #{access_token}"}
    ]
  end

  defp http_get(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, response} ->
        # Logger.debug("#{inspect(response)}")
        {_, parsed_body} = Poison.decode(response.body)
        Logger.debug("#{inspect(parsed_body)}")
        {:ok, parsed_body}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, reason}
    end
  end

  defp http_get_redirect(url, headers) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 302, headers: headers}} ->
        Logger.debug("#{inspect(headers)}")
        {"Location", location} = List.keyfind(headers, "Location", 0)
        {:ok, location}

      {:error, reason} ->
        IO.inspect(reason)
        {:error, reason}

      _ ->
        {:error, "Unknown Response"}
    end
  end

  defp http_get_download(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      _ ->
        {:error, "sorry"}
    end
  end
end
