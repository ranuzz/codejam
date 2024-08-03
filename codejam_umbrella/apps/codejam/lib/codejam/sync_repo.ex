defmodule Codejam.SyncRepo do
  @moduledoc """
  Sync github repository using latest commit hash
  (for a projectId in an organizationId)
  """

  require Logger
  alias Codejam.Github

  @doc """
  walk the commit tree and create objects in db and files in bucket
  """
  def sync_repo(project) do
    # name format is owner/rpo
    [owner, repo] = String.split(project.name, "/")

    # find the latest commit hash
    commit_sha =
      Github.get_latest_commit_hash(owner, repo, project.branch, project.organization_id)

    scan_commit(commit_sha, owner, repo, project.id, project.organization_id)
  end

  def scan_commit(commit_sha, owner, repo, project_id, organization_id) do
    # save the commit in git_object and get tree hash
    tree_sha = Github.read_commit(commit_sha, owner, repo, project_id, organization_id)
    sub_trees = Github.read_tree(tree_sha, "", owner, repo, project_id, organization_id)
    scan_trees(sub_trees, "", owner, repo, project_id, organization_id)
  end

  def scan_trees([head | tail], parent_tree_path, owner, repo, project_id, organization_id) do
    type = head[:type]

    cond do
      type == "tree" ->
        sub_trees =
          Github.read_tree(
            head[:sha],
            parent_tree_path <> "/" <> head[:path],
            owner,
            repo,
            project_id,
            organization_id
          )

        scan_trees(
          sub_trees,
          parent_tree_path <> "/" <> head[:path],
          owner,
          repo,
          project_id,
          organization_id
        )

      type == "blob" ->
        Github.read_blob(
          head[:sha],
          parent_tree_path <> "/" <> head[:path],
          owner,
          repo,
          project_id,
          organization_id
        )

      true ->
        Logger.debug("[scan_trees] invalid type")
    end

    scan_trees(tail, parent_tree_path, owner, repo, project_id, organization_id)
  end

  def scan_trees([], _parent_tree_path, _owner, _repo, _project_id, _organization_id) do
    :ok
  end
end
