defmodule Codejam.Github do
  require GithubClient

  import Ecto.Query, only: [from: 2]

  alias Codejam.Repo
  alias Codejam.Accounts.Integration
  alias Codejam.Explorer

  def get_authorization_url(state) do
    GithubClient.get_authorization_url(state)
  end

  def get_auth_authorization_url(state) do
    GithubClient.get_auth_authorization_url(state)
  end

  def get_access_token(params) do
    GithubClient.get_access_token(params)
  end

  def get_auth_access_token(params) do
    GithubClient.get_auth_access_token(params)
  end

  def search_repo(organization_id, query) do
    token = get_token(organization_id)
    GithubClient.search_repo(token, query)
  end

  def get_latest_commit_hash(owner, repo, branch, organization_id) do
    token = get_token(organization_id)
    GithubClient.get_latest_commit_hash(token, owner, repo, branch)
  end

  def read_commit(commit_sha, owner, repo, project_id, organization_id) do
    token = get_token(organization_id)
    tree = GithubClient.get_commit(token, owner, repo, commit_sha)

    if !Explorer.git_object_exist?(commit_sha, project_id) do
      Explorer.create_git_object(%{
        :object_type => "commit",
        :sha => commit_sha,
        :tree => tree,
        :project_id => project_id,
        :organization_id => organization_id
      })
    end

    tree
  end

  def read_tree(tree_sha, path, owner, repo, project_id, organization_id) do
    token = get_token(organization_id)
    trees = GithubClient.get_tree(token, owner, repo, tree_sha)

    sha_list =
      trees
      |> Enum.map(&Map.get(&1, :sha))
      |> Enum.join(",")

    if !Explorer.git_object_exist?(tree_sha, project_id) do
      Explorer.create_git_object(%{
        :object_type => "tree",
        :sha => tree_sha,
        :content => sha_list,
        :path => path,
        :project_id => project_id,
        :organization_id => organization_id
      })
    end

    trees
  end

  def read_blob(blob_sha, path, owner, repo, project_id, organization_id) do
    token = get_token(organization_id)
    content = GithubClient.get_blob(token, owner, repo, blob_sha)
    Codejam.ObjectStore.write(content, blob_sha, project_id, organization_id, Path.extname(path))

    if !Explorer.git_object_exist?(blob_sha, project_id) do
      Explorer.create_git_object(%{
        :object_type => "blob",
        :sha => blob_sha,
        :path => path,
        :project_id => project_id,
        :organization_id => organization_id
      })
    end
  end

  def user_info_auth(token) do
    GithubClient.user_info_auth(token)
  end

  defp get_token(organization_id) do
    integrations = Repo.all(from(Integration, where: [organization_id: ^organization_id]))

    if Kernel.length(integrations) === 0 do
      nil
    else
      hd(integrations).access_token
    end
  end
end
